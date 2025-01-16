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
