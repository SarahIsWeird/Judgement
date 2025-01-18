local function perform_hand_levelup(hand_type, level_diff)
    -- Taken from card.lua:1265
    update_hand_text({
        sound = 'button',
        volume = 0.7,
        pitch = 0.8,
        delay = 0.3
    }, {
        handname = localize(hand_type, 'poker_hands'),
        chips = G.GAME.hands[hand_type].chips,
        mult = G.GAME.hands[hand_type].mult,
        level = G.GAME.hands[hand_type].level
    })
    delay(1)
    level_up_hand(card, hand_type, false, level_diff or 0)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
end

SMODS.Joker {
    key = 'event_horizon',
    loc_txt = {
        name = 'Event Horizon',
        text = {
            'When blind is selected,',
            'destroy all {C:attention}held consumables{},',
            'then upgrade level of',
            'most played {C:attention}poker hand{}',
            'once {C:attention}per{} destroyed consumable.',
        },
    },
    config = {
        extra = {
            levels_per_consumable = 1,
        },
    },
    rarity = 3,
    atlas = 'Judgement',
    pos = { x = 3, y = 1 },
    cost = 10,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
    calculate = function (self, card, context)
        if not context.first_hand_drawn or context.blueprint then return end

        local consumable_count = #G.consumeables.cards
        if consumable_count == 0 then return end

        for i = consumable_count, 1, -1 do
            local consumable = G.consumeables.cards[i]
            -- Should we also remove them from the consumable list already?
            -- As it stands, two Event Horizons upgrade the hand twice.
            consumable:start_dissolve({ G.C.RED })
        end

        local highest_played_count = 0
        local highest_played_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if v.played == highest_played_count then
                highest_played_hands[#highest_played_hands+1] = k
            elseif v.played > highest_played_count then
                highest_played_count = v.played
                highest_played_hands = { k }
            end
        end

        local hand_to_upgrade = pseudorandom_element(highest_played_hands, pseudoseed('event_horizon'))
        local levels = consumable_count * card.ability.extra.levels_per_consumable
        delay(1)
        perform_hand_levelup(hand_to_upgrade, levels)
    end
}
