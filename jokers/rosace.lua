SMODS.Joker {
    key = 'rosace',
    loc_txt = {
        name = 'Rosace',
        text = {
            'Scored {C:attention}Wild cards{} gain',
            '{X:mult,C:white} X#1#{} Mult and',
            'have a {C:green}#2# in #3#{} chance',
            'to break'
        },
    },
    config = {
        extra = {
            Xmult = 1.5,
            odds = 8
        },
    },
    rarity = 2,
    atlas = 'Judgement',
    pos = { x = 1, y = 2 },
    cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    loc_vars = function(self, info_queue, card)
      return { vars = { card.ability.extra.Xmult, (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
    end,

    calculate = function(self, card, context)
        -- score on each wild card trigger
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center ~= G.P_CENTERS.m_wild then
               return
            end

            return {
                x_mult = card.ability.extra.Xmult,
                colour = G.C.RED,
                card = card
            }
        end

        -- destroy wild cards probabilistically
        if context.destroying_card and context.destroying_card.config.center == G.P_CENTERS.m_wild  and not context.blueprint then
            if not context.destroying_card.debuff and pseudorandom('rosace') < G.GAME.probabilities.normal/card.ability.extra.odds then
               return true
            end
            return false
        end
    end

}
