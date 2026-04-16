local Data = {}

export type DataSet = {
    --General
    WalkSpeed: number,
    JumpPower: number,
    MaxTilt: number,
    DoubleJumps:number,

    -- FOV
    BaseFov: number,
    SprintFov:number,

    --Sprint
    SprintSpeed: number,
    SprintJumpPower: number,

    --Dodge
    DodgeDuration: number,
    DodgeSpeed: number,
    SideDodgeCoolDown:number,
    BackDodgeCoolDown:number,
    FrontDodgeCoolDown:number,
    SpotDodgeCoolDown:number,
    SideDodgeDuration:number,
    BackDodgeDuration:number,
    FrontDodgeDuration:number,
    SpotDodgeDuration:number,
    SideDodgeSpeed:number,
    FrontDodgeSpeed:number,
    BackDashSpeed:number,
    SpotDodgeSpeed:number ,-- This is just so it everything is here its always going to be 0 regardless


    --// Vault 
    VaultBoost: number,
    VaultDuration:number,


    --//Slide
    SlideDuration:number,
    SlideSpeed:number,
    SlideCancelSpeed:number,
    


}