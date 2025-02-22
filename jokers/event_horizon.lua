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

local function dissolve_consumables()
    local count = 0

    for i = #G.consumeables.cards, 1, -1 do
        local consumable = G.consumeables.cards[i]
        if not consumable.is_dissolving then
            consumable:start_dissolve({ G.C.RED })
            count = count + 1
        end
    end

    return count
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
        if not context.setting_blind or context.blueprint then return end

        local dissolved_consumables = dissolve_consumables()
        if dissolved_consumables == 0 then return end

        -- Defaults to High Card. Seems sensible.
        local hand_to_upgrade = G.GAME.current_round.most_played_poker_hand
        local levels = dissolved_consumables * card.ability.extra.levels_per_consumable

        delay(1)
        perform_hand_levelup(hand_to_upgrade, levels)
    end
}
