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
