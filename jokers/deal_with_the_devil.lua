-- See also: /lovely/deal_with_the_devil.toml

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
