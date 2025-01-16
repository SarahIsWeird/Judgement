local function get_bishop_color_of_hand(hand)
    local hand_color = nil
    local is_bad_hand = false

    for _, v in ipairs(hand) do
        -- We ignore stone cards
        -- We only ignore wild cards if they are active. Debuffed wild cards are not wild cards.
        if v.ability.effect ~= 'Stone Card' and (v.ability.name ~= 'Wild Card' or v.debuff) then
            local this_color = (v.base.suit == 'Hearts' or v.base.suit == 'Diamonds') and 'red' or 'black'

            if hand_color == nil then
                hand_color = this_color
            elseif hand_color ~= this_color then
                is_bad_hand = true
                break
            end
        end
    end

    return hand_color, is_bad_hand
end

SMODS.Joker {
    key = 'bishop',
    loc_txt = {
        name = 'Bishop',
        text = {
            'When {C:attention}blind{} is defeated,',
            'gains {C:mult}+#1#{} Mult if all cards',
            'played were of the same {C:attention}color{}.',
            '({C:hearts}Hearts{} and {C:diamonds}Diamonds',
            '{C:attention}or{} {C:spades}Spades{} and {C:clubs}Clubs{})',
            '{C:inactive}Currently{} {C:mult}+#2#{} {C:inactive}Mult{}',
            '{C:inactive}and{} #3#'
        },
    },
    config = {
        extra = {
            mult_increase = 3,
            mult = 0,
            ready = false,
            color = nil,
        },
    },
    loc_vars = function(self, info_queue, card)
        local displayed_color
        if card.ability.extra.color == 'red' then
            displayed_color = 'wanting red'
        elseif card.ability.extra.color == 'black' then
            displayed_color = 'wanting black'
        elseif card.ability.extra.ready then
            displayed_color = 'active'
        else
            displayed_color = 'inactive'
        end

        return {
            vars = {
                card.ability.extra.mult_increase,
                card.ability.extra.mult,
                displayed_color,
            },
        }
    end,
    rarity = 1,
    atlas = 'Judgement',
    pos = { x = 1, y = 1 },
    cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if context.joker_main then
            return {
                mult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
            }
        end

        -- Copy and repetition effects don't run any checks.
        if context.repetition or context.blueprint then
            return
        end

        -- Activate Bishop
        if context.first_hand_drawn and not context.blueprint then
            card.ability.extra.ready = true

            local eval = function() return card.ability.extra.ready end
            juice_card_until(card, eval, true)
        end

        if context.before and card.ability.extra.ready then
            local hand_color, is_bad_hand = get_bishop_color_of_hand(context.scoring_hand)
            if hand_color ~= nil and card.ability.extra.color ~= nil and hand_color ~= card.ability.extra.color then
                -- If it's a different color, it doesn't matter if the hand is bad.
                is_bad_hand = true
            end

            if is_bad_hand then
                card.ability.extra.ready = false

                return {
                    card = card,
                    message = 'Not amused!',
                }
            elseif card.ability.extra.color == nil then
                card.ability.extra.color = hand_color
            end

            return
        end

        -- Same conditions as Gross Michael.
        if context.end_of_round and context.game_over == false then
            if card.ability.extra.ready then
                card.ability.extra.ready = false
                card.ability.extra.color = nil
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_increase

                return {
                    message = 'Upgraded!',
                    colour = G.C.MULT,
                    card = card,
                }
            end
        end
    end,
}
