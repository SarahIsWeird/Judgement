local debug = true

SMODS.Atlas {
    key = 'Judgement',
    path = 'Judgement.png',
    px = 71,
    py = 95,
}

local jokers_to_load = {
    -- Common jokers
    'addiction',
    'bishop',
    'triangle_joker',
    'traveller',
    'imposter_syndrome',

    -- Uncommon jokers
    'pet_rock',
    'rosace',

    -- Rare jokers
    'deal_with_the_devil',
    'event_horizon',
}

for _, name in ipairs(jokers_to_load) do
    local chunk, err = SMODS.load_file('jokers/' .. name .. '.lua')
    assert(err == nil, ('Failed to load jokers/%s.lua: %s'):format(name, err))

    chunk()
end

-------- Debug stuff ---------

if debug then
    --- Debug keybinds

    SMODS.Keybind {
        key = 'create_joker',
        key_pressed = 'p',
        held_keys = { 'lctrl' },
        action = function ()
            if G.CONTROLLER.held_keys['lshift'] then
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_jdg_pet_rock',
                })
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_jdg_triangle_joker',
                })
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_jdg_addiction',
                })
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_jdg_deal_with_the_devil',
                })
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_blueprint',
                })
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_jdg_bishop',
                })
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_jdg_traveller',
                })
                SMODS.add_card({
                    set = 'Joker',
                    key = 'j_jdg_rosace'
                })
            end

            SMODS.add_card({
                set = 'Joker',
                key = 'j_jdg_imposter_syndrome',
            })
        end
    }

    SMODS.Keybind {
        key = 'make_consumable',
        key_pressed = 'c',
        held_keys = { 'lctrl' },
        action = function ()
            local card = SMODS.create_card({
                set = 'Tarot',
            })

            card:add_to_deck()
            G.consumeables:emplace(card)
        end
    }

    SMODS.Keybind {
        key = 'make_stone',
        key_pressed = 's',
        held_keys = { 'lctrl' },
        action = function ()
            for i = 1, #G.hand.highlighted do
                G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_stone)
            end
        end
    }

    SMODS.Keybind {
        key = 'make_wild',
        key_pressed = 'w',
        held_keys = { 'lctrl' },
        action = function ()
            for i = 1, #G.hand.highlighted do
                G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_wild)
            end
        end
    }

    local function get_next_edition(edition)
        if not edition then return {foil=true} end
        if edition.foil then return {holo=true} end
        if edition.holo then return {polychrome=true} end
        if edition.polychrome then return {negative=true} end
        return nil
    end

    local function get_next_seal(seal)
        if not seal then return 'Gold' end
        if seal == 'Gold' then return 'Red' end
        if seal == 'Red' then return 'Blue' end
        if seal == 'Blue' then return 'Purple' end
        if seal == 'Purple' then return nil end
    end

    SMODS.Keybind {
        key = 'make_edition',
        key_pressed = 'e',
        held_keys = { 'lctrl' },
        action = function ()
            for i = 1, #G.hand.highlighted do
                local card = G.hand.highlighted[i]
                card:set_edition(get_next_edition(card.edition), false, false)
            end
        end
    }

    SMODS.Keybind {
        key = 'make_seal',
        key_pressed = 't',
        held_keys = { 'lctrl' },
        action = function ()
            for i = 1, #G.hand.highlighted do
                local card = G.hand.highlighted[i]
                card:set_seal(get_next_seal(card.seal), false, false)
            end
        end
    }

    SMODS.Keybind {
        key = 'jdg_restart',
        key_pressed = 'n',
        action = function()
            SMODS.restart_game()
        end
    }
end
