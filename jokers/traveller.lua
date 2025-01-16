SMODS.Joker {
    key = 'traveller',
    loc_txt = {
        name = 'Traveller',
        text = {
            '{C:attention}+#1#{} consumable slots'
        },
    },
    config = {
        extra = {
            additional_consumable_slots = 2,
        },
    },
    rarity = 1,
    atlas = 'Judgement',
    pos = { x = 1, y = 3 },
    cost = 5,
    blueprint_compat = false, -- I think this could be cheesed pretty hard w/ blueprint
    perishable_compat = true,
    eternal_compat = true,
    loc_vars = function(self, info_queue, card)
      return { vars = { card.ability.extra.additional_consumable_slots } }
    end,

    add_to_deck = function(self, card, from_debuff)
       G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.additional_consumable_slots
    end,

    remove_from_deck = function(self, card, from_debuff)
      G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.additional_consumable_slots
    end

}
