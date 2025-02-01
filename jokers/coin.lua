SMODS.Joker {
    key = 'coin',
    loc_txt = {
        name = 'Coin',
        text = {
            'On odd numbered rounds',
            'multiply probabilities by {C:attention}#1#{}',
            'On even numbered rounds',
            'divide probabilities by {C:attention}#1#{}',
        },
    },
    config = { extra = { probability_scale_factor = 2 } },
    rarity = 1,
    atlas = 'Judgement',
    pos = { x = 2, y = 3 },
    cost = 4,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.probability_scale_factor } }
    end,

    add_to_deck = function(self, card, from_debuff)
        if G.GAME.round % 2 == 0 then
            for k, v in pairs(G.GAME.probabilities) do 
                G.GAME.probabilities[k] = v/card.ability.extra.probability_scale_factor
            end
        end
        if G.GAME.round % 2 == 1 then
            for k, v in pairs(G.GAME.probabilities) do 
                G.GAME.probabilities[k] = v*card.ability.extra.probability_scale_factor
            end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        -- Do the inverse of adding to the deck
        if G.GAME.round % 2 == 0 then
            for k, v in pairs(G.GAME.probabilities) do 
                G.GAME.probabilities[k] = v*card.ability.extra.probability_scale_factor
            end
        end
        if G.GAME.round % 2 == 1 then
            for k, v in pairs(G.GAME.probabilities) do 
                G.GAME.probabilities[k] = v/card.ability.extra.probability_scale_factor
            end
        end
    end,

    calculate = function(self, card, context)
        if context.setting_blind and context.main_eval then
            if G.GAME.round % 2 == 0 then
                for k, v in pairs(G.GAME.probabilities) do 
                    G.GAME.probabilities[k] = v/(card.ability.extra.probability_scale_factor^2)
                end
            end
            if G.GAME.round % 2 == 1 then
                for k, v in pairs(G.GAME.probabilities) do 
                    G.GAME.probabilities[k] = v*(card.ability.extra.probability_scale_factor^2)
                end
            end
        end

    end
}
