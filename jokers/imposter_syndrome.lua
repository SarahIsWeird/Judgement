SMODS.Joker {
    key = 'imposter_syndrome',
    loc_txt = {
        name = 'Imposter Syndrome',
        text = {
            'If {C:attention}played hand{} contains a Flush',
            'turn a random unenhanced scoring',
            'card into a {C:attention}wild card{}',
        },
    },
    config = {},
    rarity = 1,
    atlas = 'Judgement',
    pos = { x = 2, y = 2 },
    cost = 5,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
    calculate = function(self, card, context)
        -- change scoring card to wild card
        if context.before and context.scoring_name:find("Flush") ~= nil then
            non_enhanced_cards = {}
            for i = 1, #context.scoring_hand do
                if next(SMODS.get_enhancements(context.scoring_hand[i])) == nil then
                    table.insert(non_enhanced_cards, context.scoring_hand[i])
                end
            end
            
            card_to_enhance = pseudorandom_element(non_enhanced_cards)

            if card_to_enhance ~= nil then
                card_to_enhance:set_ability(G.P_CENTERS.m_wild, nil, true)
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        card_to_enhance:juice_up()
                        return true
                    end
                }))
                return {
                    message = 'Wild',
                    colour = G.C.YELLOW,
                    card = card
                }
            end
        end

    end


}
