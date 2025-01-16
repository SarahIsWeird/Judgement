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
