--script by theMark
cashRegisterNumTable = {7, 8, 9, 4, 5, 6, 1, 2, 3}
activeTableText = 'first'
selectedButton = 1
activePanel = 1
handlers = {
    {
        name = 'onClientRender',
        func = function(...)
            return renderDialoguePanel(...)
        end
    },
    -- {
    --     name = 'onClientKey',
    --     func = function(...)
    --         return selectSpeechPanelButton(...)
    --     end
    -- }
}
pedText = {
    ['first'] = {
        ['question'] = {text = 'Mit akar maga azzal a fegyverrel? (Nyomj ENTERT kiválasztáshoz)'},
        ['answers'] = {'A pénztárgép kódját!', ' Semmit'},
        ['meAction'] = {'A pénztárgép kódját!', 'Semmit'}
    },
    -- ['two'] = {
    --     ['question'] = {text = 'Eladó: Mit csinál maga azzal a fegyverrel?'},
    --     ['answers'] = {'Én:Ez egy bolti rablás tegye fel a kezeit és adja meg a pénztárgép kódját!', 'Én:Megfogom ölni ha, nem mondja meg most azonnal a kódot!'},
    --     ['pedReply'] = {'Eladó: Nem tehetem!'}
    -- },
    ['ForASuccessfulMinigame'] = {
        ['cashRegisterCode'] = {'Eladó: A pénztárgép kódja: '}
    }
}

randomTableTextString = ''
randomTableText = {'first', 'two'}