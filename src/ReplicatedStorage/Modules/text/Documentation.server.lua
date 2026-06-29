--[[
    ===========================================================================
    CUSTOM TEXT RENDERING ENGINE: TAG DOCUMENTATION & USAGE
    ===========================================================================
    
    This system parses markup tags embedded directly within string lines to provide 
    dynamic effects, visual formatting, animations, and inline pacing.

    ---------------------------------------------------------------------------
    1. FORMATTING & VISUAL EFFECT TAGS
    ---------------------------------------------------------------------------
    
    <colour:#HEX> ... </colour>
        Changes the text color using 3-digit or 6-digit hexadecimal codes.
        * Usage: "Hello <colour:#ff0000>Red Text</colour>!"
        * Usage (Short): "This is <colour:#3a3>Green Text</colour>."
        
    <shake> ... </shake>
        Applies a localized, continuous positional jittering effect to characters.
        Useful for emphasizing anger, excitement, or tension.
        * Usage: "Get out of here, <shake>NOW!</shake>"
        
    <corrupt> ... </corrupt>
        Distorts text by applying vertical scattering, unexpected scaling shifts,
        and flickering image transparency. Excellent for glitch/error effects.
        * Usage: "System status: <corrupt>FATAL_ERROR_0x99</corrupt>"

    ---------------------------------------------------------------------------
    2. INLINE PACING & CONTROLS (Self-Closing)
    ---------------------------------------------------------------------------
    
    <pause:SECONDS>
        Halts typewriter printing for a specified duration in seconds before 
        continuing onto the next character. Does not work in instant-finish mode.
        * Usage: "Wait for it... <pause:1.5> Boom!"
        * Usage: "Yes. <pause:0.5> No. <pause:0.5> Maybe."

    ---------------------------------------------------------------------------
    3. GAME ENGINE & GAMEPLAY INTERACTION TAGS
    ---------------------------------------------------------------------------
    
    <emotion:NAME> ... </emotion>
        Fires the 'DialogueBindable' with ("PlayAnimation", "NAME") to trigger 
        character model animations matching the dialogue mood. 
        * UI_inject note: Fires only once when the first letter of the block prints.
        * Usage: "<emotion:Angry>I can't believe you did that!</emotion>"
        
    <sound:rbxassetid://ID>
        Instantiates and plays a one-shot asset audio clip through the user's
        PlayerGui or CurrentCamera. Self-cleans after 2 seconds.
        * Usage: "<sound:rbxassetid://12345678> *Door slams shut*"

    ---------------------------------------------------------------------------
    4. SYSTEM SPECIAL HEADERS (Subtitles Only)
    ---------------------------------------------------------------------------
    
    <h>TEXT<h>
        Declares header text (e.g., character names) in the subtitle manager. 
        When found, the system clears the previous header, fades in the new 
        header string above the subtitles, and clears it when the line expires.
        * Usage: "<h>Narrator<h>Once upon a time..."

    ===========================================================================
    COMBINED EXAMPLE USAGE:
    ===========================================================================
    
    local dialogue = "<h>Glitched Boss<h><emotion:Threaten>You think you can defeat me? <pause:0.4> <colour:#ff0000><shake>PREPARE TO DIE!</shake></colour></emotion>"
    CustomTextModule.subtitles(dialogue, player)
--]]