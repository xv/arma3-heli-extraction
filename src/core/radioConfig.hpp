class CfgRadio
{
    sounds[] =
    {
        radio_beep_to,
        radio_beep_from
    };

    class radio_beep_to
    {
        name = "radio_beep_to";
        sound[] = {"\core\sounds\radio_beep_to.ogg", db +0, 1.0};
        title = "";
    };
    
    class radio_beep_from
    {
        name = "radio_beep_from";
        sound[] = {"\core\sounds\radio_beep_from.ogg", db +0, 1.0};
        title = "";
    };
};