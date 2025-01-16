SMODS.Atlas {
    key = 'Judgement',
    path = 'Judgement.png',
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = 'pet_rock',
    loc_txt = {
        name = 'Pet Rock',
        text = {
            '{C:attention}Retrigger{} played {C:attention}stone{}',
            'cards once, and',
            'another time if they',
            'have a {C:attention}seal{} or {C:attention}edition{}.'
        },
    },
    config = {
        extra = {
            reps_stone = 1,
            reps_seal = 1,
            reps_edition = 1,
        },
    },
    rarity = 2,
    atlas = 'Judgement',
    pos = { x = 0, y = 0 },
    cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea ~= G.play or not context.repetition or context.repetition_only then
            return
        end

        if context.other_card.config.center ~= G.P_CENTERS.m_stone then
            return
        end

        local repetitions = card.ability.extra.reps_stone
        if context.other_card.edition then
            repetitions = repetitions + 1
        end
        if context.other_card.seal then
            repetitions = repetitions + 1
        end

        return {
            message = 'Again!',
            repetitions = repetitions,
            card = context.other_card,
        }
    end,
}

SMODS.Joker {
    key = 'triangle_joker',
    loc_txt = {
        name = 'Triangle Joker',
        text = {
            'Each played {C:attention}3{} gives',
            '{C:mult}+#1#{} Mult per {C:attention}played{}',
            '{C:attention}3{} when {C:attention}scored{}.',
        }
    },
    config = {
        extra = {
            mult_per_three = 3,
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_per_three } }
    end,
    rarity = 1,
    atlas = 'Judgement',
    pos = { x = 2, y = 0 },
    cost = 3,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if not context.individual or context.cardarea ~= G.play then return end
        if context.other_card:get_id() ~= 3 then return end

        local threes = 0
        for _, v in ipairs(context.full_hand) do
            if v:get_id() == 3 then
                threes = threes + 1
            end
        end

        return {
            card = context.other_card,
            mult = threes * card.ability.extra.mult_per_three,
        }
    end,
}

SMODS.Joker {
    key = 'addiction',
    loc_txt = {
        name = 'Addiction',
        text = {
            'Scored {C:attention}7{}s have a {C:attention}#1# in #2#{}',
            'change of retriggering,',
            'up to {C:attention}#3#{} additional times.',
        }
    },
    config = {
        extra = {
            retrigger_odds = 7,
            retrigger_limit = 7,
        },
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                G.GAME.probabilities.normal or 1,
                card.ability.extra.retrigger_odds,
                card.ability.extra.retrigger_limit,
            },
        }
    end,
    rarity = 1,
    atlas = 'Judgement',
    pos = { x = 3, y = 0 },
    cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    calculate = function(self, card, context)
        if context.cardarea ~= G.play or not context.repetition or context.repetition_only then
            return
        end

        if context.other_card:get_id() ~= 7 then
            return
        end

        local repetitions = 0
        for i = 1, card.ability.extra.retrigger_limit do
            if pseudorandom('addiction') < G.GAME.probabilities.normal / card.ability.extra.retrigger_odds then
                repetitions = repetitions + 1
            end
        end

        return {
            message = localize('k_again_ex'),
            repetitions = repetitions,
            card = context.other_card,
        }
    end,
}

SMODS.Joker {
    key = 'deal_with_the_devil',
    loc_txt = {
        name = 'Deal with the Devil',
        text = {
            'Sets {C:mult}Mult{} to {C:attention}0{}.',
            'Upgrade level of',
            'played {C:attention}poker hand{}.',
            '{s:0.8}Was this a good idea?{}'
        },
    },
    rarity = 3,
    atlas = 'Judgement',
    pos = { x = 0, y = 1 },
    cost = 9,
    blueprint_compat = false, -- TODO: What to do with this?
    perishable_compat = true,
    eternal_compat = true, -- Mean.
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before then
            level_up_hand(card, context.scoring_name, false)

            return {
                message = 'Oof!',
            }
        end;
    end,
}

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

        if context.repetition or context.blueprint then
            return
        end

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

--- Debug keybinds

SMODS.Keybind {
    key = 'create_joker',
    key_pressed = 'p',
    held_keys = { 'lctrl' },
    action = function ()
        if G.CONTROLLER.held_keys['lshift'] then
            SMODS.add_card({
                set = 'Joker',
                key = 'j_jdg_pet_rock',
            })
            SMODS.add_card({
                set = 'Joker',
                key = 'j_jdg_triangle_joker',
            })
            SMODS.add_card({
                set = 'Joker',
                key = 'j_jdg_addiction',
            })
            SMODS.add_card({
                set = 'Joker',
                key = 'j_jdg_deal_with_the_devil',
            })
            SMODS.add_card({
                set = 'Joker',
                key = 'j_blueprint',
            })  
        end

        SMODS.add_card({
            set = 'Joker',
            key = 'j_jdg_bishop',
        })
    end
}

SMODS.Keybind {
    key = 'make_stone',
    key_pressed = 's',
    held_keys = { 'lctrl' },
    action = function ()
        for i = 1, #G.hand.highlighted do
            G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_stone)
        end
    end
}

local function get_next_edition(edition)
    if not edition then return {foil=true} end
    if edition.foil then return {holo=true} end
    if edition.holo then return {polychrome=true} end
    if edition.polychrome then return {negative=true} end
    return nil
end

local function get_next_seal(seal)
    if not seal then return 'Gold' end
    if seal == 'Gold' then return 'Red' end
    if seal == 'Red' then return 'Blue' end
    if seal == 'Blue' then return 'Purple' end
    if seal == 'Purple' then return nil end
end

SMODS.Keybind {
    key = 'make_edition',
    key_pressed = 'e',
    held_keys = { 'lctrl' },
    action = function ()
        for i = 1, #G.hand.highlighted do
            local card = G.hand.highlighted[i]
            card:set_edition(get_next_edition(card.edition), false, false)
        end
    end
}

SMODS.Keybind {
    key = 'make_seal',
    key_pressed = 't',
    held_keys = { 'lctrl' },
    action = function ()
        for i = 1, #G.hand.highlighted do
            local card = G.hand.highlighted[i]
            card:set_seal(get_next_seal(card.seal), false, false)
        end
    end
}

SMODS.Keybind {
    key = 'jdg_restart',
    key_pressed = 'n',
    action = function()
        SMODS.restart_game()
    end
}
