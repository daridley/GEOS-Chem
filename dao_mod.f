! $Id: dao_mod.f,v 1.4 2004/03/24 20:52:29 bmy Exp $
      MODULE DAO_MOD
!
!******************************************************************************
!  Module DAO_MOD contains both arrays that hold DAO met fields, as well as
!  subroutines that compute, interpolate, or otherwise process DAO met field 
!  data. (bmy, 6/27/00, 12/9/03)
!
!  Module Variables:
!  ============================================================================
!
!  GEOS-CHEM 6-hr synoptic met fields (a.k.a. "I-6 fields"):
!  ----------------------------------------------------------------------------
!  (1 ) ALBD1    (REAL*8 ) : Sfc albedo at start of 6h step      [unitless]
!  (2 ) ALBD2    (REAL*8 ) : Sfc albedo at end   of 6h step      [unitless]
!  (3 ) ALBD     (REAL*8 ) : Interpolated surface albedo         [unitless] 
!  (4 ) LWI      (INTEGER) : Land-Water flags                    [unitless]
!  (5 ) PS1      (REAL*8 ) : Sfc pressure at start of 6h  step   [hPa]
!  (6 ) PS2      (REAL*8 ) : Sfc pressure at end   of 6h  step   [hPa] 
!  (7 ) PSC2     (REAL*8 ) : Sfc pressure at end   of dyn step   [hPa]
!  (8 ) SLP      (REAL*8 ) : Sea level pressure (GEOS-3)         [hPa]
!  (9 ) SPHU1    (REAL*8 ) : Spec. Humidity at start of 6h step  [g H2O/kg air]
!  (10) SPHU2    (REAL*8 ) : Spec. Humidity at end   of 6h step  [g H2O/kg air]
!  (11) SPHU     (REAL*8 ) : Interpolated specific humidity      [g H2O/kg air]
!  (12) TMPU1    (REAL*8 ) : Temperature at start of 6h step     [K]
!  (13) TMPU2    (REAL*8 ) : Temperature at end   of 6h step     [K]
!  (14) T        (REAL*8 ) : Interpolated temperature            [K]  
!  (15) TROPP    (REAL*8 ) : Tropopause pressure (GEOS-3)        [hPa]      
!  (16) UWND1    (REAL*8 ) : Zonal wind at start of 6h step      [m/s]
!  (17) UWND2    (REAL*8 ) : Zonal wind at end   of 6h step      [m/s]
!  (18) UWND     (REAL*8 ) : Interpolated zonal wind             [m/s]
!  (19) VWND1    (REAL*8 ) : Meridional wind at start of 6h step [m/s]
!  (20) VWND2    (REAL*8 ) : Meridional wind at end of 6h step   [m/s]
!  (21) VWND     (REAL*8 ) : Interpolated meridional wind        [m/s]
!
!  GEOS-CHEM 6-hr average cloud fields (a.k.a. "A-6 fields"):  
!  ----------------------------------------------------------------------------
!  (22) CLDTOPS  (INTEGER) : Cloud top height level              [unitless]
!  (23) CLDMAS   (REAL*8 ) : Cloud mass flux                     [kg/m2/600s]
!  (24) DTRAIN   (REAL*8 ) : Cloud detrainment                   [kg/m2/600s]
!  (25) HKBETA   (REAL*8 ) : GEOS-4 Hack overshoot parameter     [unitless]
!  (26) HKETA    (REAL*8 ) : GEOS-4 Hack convective mass flux    [kg/m2/s]
!  (27) MOISTQ   (REAL*8 ) : Tendency of SPHU field          [g H2O/kg air/day]
!  (28) CLMOSW   (REAL*8 ) : GEOS-1 max overlap cloud fraction   [unitless]
!  (29) CLROSW   (REAL*8 ) : GEOS-1 random overlap cloud frac.   [unitless]
!  (30) CLDF     (REAL*8 ) : Total 3-D cloud fraction            [unitless]
!  (31) OPTDEP   (REAL*8 ) : GEOS-3 grid box optical depth       [unitless]
!  (32) OPTD     (REAL*8 ) : Grid box optical depth (all grids)  [unitless]
!  (33) ZMEU     (REAL*8 ) : GEOS-4 Z&M updraft entrainment      [Pa/s]
!  (34) ZMMD     (REAL*8 ) : GEOS-4 Z&M downdraft mass flux      [Pa/s]
!  (35) ZMMU     (REAL*8 ) : GEOS-4 Z&M updraft mass flux        [Pa/s]
! 
!  GEOS-CHEM 3-hr surface fields (a.k.a. "A-3 fields"):
!  ----------------------------------------------------------------------------
!  (36) GWETTOP  (REAL*8 ) : GEOS-4 topsoil wetness              
!  (37) HFLUX    (REAL*8 ) : Sensible heat flux                  [W/m2]
!  (38) PARDF    (REAL*8 ) : Photosyn active diffuse radiation   [W/m2]
!  (39) PARDR    (REAL*8 ) : Photosyn active direct radiation    [W/m2]
!  (40) PBL      (REAL*8 ) : Mixed layer depth                   [hPa]
!  (41) PREACC   (REAL*8 ) : Total precip at the ground          [mm H2O/day]
!  (42) PRECON   (REAL*8 ) : Convective precip at the ground     [mm H2O/day]
!  (43) RADLWG   (REAL*8 ) : Net upward LW rad at the ground     [W/m2]
!  (44) RADSWG   (REAL*8 ) : Net downward SW rad at the ground   [W/m2]
!  (45) SNOW     (REAL*8 ) : Snow cover (H2O equivalent)         [mm H2O]
!  (46) TS       (REAL*8 ) : Surface air temperature             [K]
!  (47) TSKIN    (REAL*8 ) : Surface ground/sea surface temp     [K]
!  (48) U10M     (REAL*8 ) : Zonal wind at 10 m altitude         [m/s]
!  (59) USTAR    (REAL*8 ) : Friction velocity                   [m/s]
!  (50) V10M     (REAL*8 ) : Meridional wind at 10 m altitude    [m/s]
!  (51) WIND_10M (REAL*8 ) : Wind speed @ 10 m for GEOS-STRAT    [m/s]
!  (52) Z0       (REAL*8 ) : Roughness height                    [m]
!
!  Computed meteorolgical quantities:
!  ----------------------------------------------------------------------------
!  (54) AD       (REAL*8 ) : Dry air mass                        [kg]
!  (55) AIRVOL   (REAL*8 ) : Volume of air in grid box           [m3]
!  (56) AIRDEN   (REAL*8 ) : Density of air in grid box          [kg/m3]
!  (57) AVGW     (REAL*8 ) : Mixing ratio of water vapor         [v/v]
!  (58) BXHEIGHT (REAL*8 ) : Grid box height                     [m]
!  (59) DELP     (REAL*8 ) : Pressure thickness of grid box      [hPa]
!  (60) OBK      (REAL*8 ) : Monin-Obhukov length                [m]
!  (61) RH       (REAL*8 ) : Relative humidity                   [%]
!  (62) SUNCOS   (REAL*8 ) : COSINE( solar zenith angle )        [unitless]
!  (63) SUNCOSB  (REAL*8 ) : COSINE( SZA ) at next chem time     [unitless]
!
!  Other variables:
!  ----------------
!  (64) USE_WIND_10M (LOGICAL) : Flag to denote if make_wind10m.f is called 
!
!  Module Routines:
!  ============================================================================
!  (1 ) AVGPOLE        : computes average pressure for polar boxes
!  (2 ) AIRQNT         : computes air mass and related quantities    
!  (3 ) INTERP         : interpolates I-6 fields to current timestep
!  (4 ) IS_LAND        : returns TRUE if (I,J) is a surface land box
!  (5 ) IS_WATER       : returns TRUE if (I,J) is a surface water box
!  (6 ) MAKE_AVGW      : computes AVGW [mixing ratio of H2O] from SPHU
!  (7 ) MAKE_RH        : computes relative humidity from SPHU and T
!  (8 ) MAKE_WIND10M   : makes the 10 m wind for GEOS-STRAT
!  (9 ) MOLENGTH       : computes the Monin-Obhukov length
!  (10) COSSZA         : computes the cosine of the solar zenith angle
!  (11) CONVERT_UNITS  : Converts STT tracer array to/from [kg] and [v/v]
!  (12) INIT_DAO       : allocates memory for all met field arrays
!  (13) CLEANUP_DAO    : deallocates memory for all met field arrays
!
!  GEOS-CHEM modules referenced by dao_mod.f
!  ============================================================================
!  (1 ) diag_mod.f     : Module containing GEOS-CHEM diagnostic arrays
!  (2 ) error_mod.f    : Module containing I/O error and NaN check routines
!  (3 ) grid_mod.f     : Module containing horizontal grid information
!  (4 ) pressure_mod.f : Module containing routines to compute P(I,J,L) 
!  (5 ) time_mod.f     : Module containing routines to compute date & time
!
!  NOTES:
!  (1 ) Added sea level pressure (SLP) met field for GEOS-3 (bmy, 10/10/00)
!  (2 ) Moved MAKE_QQ to "wetscav_mod.f" (bmy, 10/12/00)
!  (3 ) Now get LWI from ALBEDO for GEOS-3 in routines IS_LAND and
!        IS_WATER (bmy, 4/4/01)
!  (4 ) Define OPTDEP allocatable array for GEOS-3 -- this is the grid 
!        box optical depth and is now stored as a met field (bmy, 8/15/01)
!  (5 ) Updated comments (bmy, 9/4/01)
!  (6 ) Now make AVGW an allocatable module array.  Also replace obsolete
!        parameters {IJL}GCMPAR with IIPAR,JJPAR,LLPAR. (bmy, 9/27/01)
!  (7 ) Remove arguments LMAKEPW, PW, and LM from AIRQNT (bmy, 10/3/01)
!  (8 ) Remove obsolete code from 9/01 (bmy, 10/23/01)
!  (9 ) Bug fixes in IS_LAND and IS_WATER.  Also cosmetic changes and 
!        updated some comments. (mje, bmy, 1/9/02)
!  (10) Now add additional array PSC2 in order to pass to TPCORE, which will
!        fix the mixing ratio bug.  Compute PSC2 in subroutine INTERP.
!        Now bundle "convert_units.f" into "dao_mod.f".  Updated comments.
!        (bmy, 3/27/02)
!  (11) Updated comments (bmy, 5/28/02)
!  (12) Replaced all instances of IM with IIPAR and JM with JJPAR, in order
!        to prevent namespace confusion for the new TPCORE (bmy, 6/25/02)
!  (13) Eliminated PS, PSC arrays.  Now reference "pressure_mod.f".  Also
!        updated AIRQNT for hybrid grid.  Added routine MAKE_RH to this
!        module. (dsa, bdf, bmy, 8/27/02)
!  (14) Added arrays AD, BXHEIGHT, and T to "dao_mod.f".  Also removed 
!        obsolete code from 8/02 from several module routines.  Now 
!        references "error_mod.f".  Remove all references to QQ, it is now
!        declared in "wetscav_mod.f".  (bmy, 11/8/02)
!  (15) Now references "grid_mod.f".  Also added PHIS field, which was
!        formerly stored as PALTD in "CMN".  Added bug fix in routine
!        AVGPOLE for 1x1 nested grid. (bmy, 3/11/03)
!  (16) Added SUNCOSB array for SMVGEAR II.  Also removed KZZ array, since
!        that is now obsolete. (bmy, 4/28/03)
!  (17) Now moved MAKE_CLDFRC into "a6_read_mod.f".  Added HKBETA, HKETA, 
!        TSKIN, GWETTOP, ZMEU, ZMMD, ZMMU, PARDF, PARDR fields for 
!        GEOS-4/fvDAS. (bmy, 6/25/03)
!  (18) Added CLDFRC, RADSWG, RADLWG, SNOW arrays (bmy, 12/9/03)
!******************************************************************************
!
      IMPLICIT NONE

      !=================================================================
      ! MODULE VARIABLES
      !=================================================================

      ! I-6 fields
      INTEGER, ALLOCATABLE :: LWI(:,:)
      REAL*8,  ALLOCATABLE :: ALBD1(:,:)
      REAL*8,  ALLOCATABLE :: ALBD2(:,:)
      REAL*8,  ALLOCATABLE :: ALBD (:,:)
      REAL*8,  ALLOCATABLE :: PHIS(:,:)
      REAL*8,  ALLOCATABLE :: PS1(:,:)
      REAL*8,  ALLOCATABLE :: PS2(:,:)
      REAL*8,  ALLOCATABLE :: PSC2(:,:)
      REAL*8,  ALLOCATABLE :: SLP(:,:)
      REAL*8,  ALLOCATABLE :: SPHU1(:,:,:)
      REAL*8,  ALLOCATABLE :: SPHU2(:,:,:)
      REAL*8,  ALLOCATABLE :: SPHU (:,:,:)
      REAL*8,  ALLOCATABLE :: TMPU1(:,:,:)
      REAL*8,  ALLOCATABLE :: TMPU2(:,:,:)
      REAL*8,  ALLOCATABLE :: T(:,:,:)
      REAL*8,  ALLOCATABLE :: TROPP(:,:)
      REAL*8,  ALLOCATABLE :: UWND(:,:,:)
      REAL*8,  ALLOCATABLE :: UWND1(:,:,:)
      REAL*8,  ALLOCATABLE :: UWND2(:,:,:)
      REAL*8,  ALLOCATABLE :: VWND(:,:,:)
      REAL*8,  ALLOCATABLE :: VWND1(:,:,:)
      REAL*8,  ALLOCATABLE :: VWND2(:,:,:)

      ! A-6 fields
      INTEGER, ALLOCATABLE :: CLDTOPS(:,:)
      REAL*8,  ALLOCATABLE :: CLDF(:,:,:)
      REAL*8,  ALLOCATABLE :: CLDMAS(:,:,:)
      REAL*8,  ALLOCATABLE :: CLMOSW(:,:,:)
      REAL*8,  ALLOCATABLE :: CLROSW(:,:,:)
      REAL*8,  ALLOCATABLE :: DTRAIN(:,:,:)
      REAL*8,  ALLOCATABLE :: HKBETA(:,:,:)
      REAL*8,  ALLOCATABLE :: HKETA(:,:,:)
      REAL*8,  ALLOCATABLE :: MOISTQ(:,:,:)
      REAL*8,  ALLOCATABLE :: OPTDEP(:,:,:)
      REAL*8,  ALLOCATABLE :: OPTD(:,:,:)
      REAL*8,  ALLOCATABLE :: ZMEU(:,:,:)
      REAL*8,  ALLOCATABLE :: ZMMD(:,:,:)
      REAL*8,  ALLOCATABLE :: ZMMU(:,:,:)

      ! A-3 fields
      LOGICAL              :: USE_WIND_10M   ! Internal flag
      REAL*8,  ALLOCATABLE :: CLDFRC(:,:)
      REAL*8,  ALLOCATABLE :: GWETTOP(:,:)
      REAL*8,  ALLOCATABLE :: HFLUX(:,:)
      REAL*8,  ALLOCATABLE :: PARDF(:,:)
      REAL*8,  ALLOCATABLE :: PARDR(:,:)
      REAL*8,  ALLOCATABLE :: PBL(:,:)
      REAL*8,  ALLOCATABLE :: PREACC(:,:)
      REAL*8,  ALLOCATABLE :: PRECON(:,:)
      REAL*8,  ALLOCATABLE :: RADLWG(:,:)
      REAL*8,  ALLOCATABLE :: RADSWG(:,:)
      REAL*8,  ALLOCATABLE :: SNOW(:,:)
      REAL*8,  ALLOCATABLE :: TS(:,:)
      REAL*8,  ALLOCATABLE :: TSKIN(:,:)
      REAL*8,  ALLOCATABLE :: U10M(:,:)
      REAL*8,  ALLOCATABLE :: USTAR(:,:)  
      REAL*8,  ALLOCATABLE :: V10M(:,:)
      REAL*8,  ALLOCATABLE :: WIND_10M(:,:)
      REAL*8,  ALLOCATABLE :: Z0(:,:)

      ! Computed quantities
      REAL*8,  ALLOCATABLE :: AD(:,:,:)
      REAL*8,  ALLOCATABLE :: AIRDEN(:,:,:)
      REAL*8,  ALLOCATABLE :: AIRVOL(:,:,:)
      REAL*8,  ALLOCATABLE :: AVGW(:,:,:)
      REAL*8,  ALLOCATABLE :: BXHEIGHT(:,:,:)
      REAL*8,  ALLOCATABLE :: DELP(:,:,:)
      REAL*8,  ALLOCATABLE :: RH(:,:,:)
      REAL*8,  ALLOCATABLE :: SUNCOS(:)
      REAL*8,  ALLOCATABLE :: SUNCOSB(:)

      !=================================================================
      ! MODULE ROUTINES -- follow below the "CONTAINS" statement 
      !=================================================================
      CONTAINS
   
!------------------------------------------------------------------------------

      SUBROUTINE AVGPOLE( Z ) 
!
!******************************************************************************
!  Subroutine AVGPOLE computes average quantity near polar caps, defined 
!  by (J = 1, 2) and (J = JJPAR-1, JJPAR).  (bmy, 1/30/98, 3/11/03)
! 
!  Arguments as Input:
!  ===========================================================================
!  (1 ) Z (REAL*8) : Quantity to be averaged over the pole (usually PS)
!                                               
!  NOTES:                            
!  (1 ) AVGPOLE is written in Fixed-Form Fortran 90.  Use F90 syntax
!        for declarations, etc (bmy, 4/14/99)
!  (2 ) MAIN now passes the Harvard CTM variable for surface area of
!        a gridbox, DXYP(JGLOB), to AVGPOLE.  Use window offset
!        J+J0 when accessing DXYP.  Add JGLOB to the parameter list.
!  (3 ) Added this routine to "dao_mod.f" (bmy, 6/27/00)
!  (4 ) Updated comments (bmy, 4/4/01)
!  (5 ) Now replaced DXYP(J) with routine GET_AREA_M2 of "grid_mod.f"
!        Now also return immediately if GRID1x1 is selected. (bmy, 3/11/03)
!******************************************************************************
!
      ! References to F90 modules
      USE GRID_MOD, ONLY : GET_AREA_M2

#     include "CMN_SIZE"

      ! Arguments
      REAL*8, INTENT(INOUT) :: Z(IIPAR,JJPAR)

      ! Local varaibles
      INTEGER               :: I, J

      REAL*8                :: TOTAL_Z1, TOTAL_Z2, TOTAL_Z3, TOTAL_Z4
      REAL*8                :: TOTAL_A1, TOTAL_A2, TOTAL_A3, TOTAL_A4

      !=================================================================
      ! AVGPOLE begins here!                                                  
      !=================================================================

#if   defined( GRID1x1 )
      ! 1x1 window grid does not extend to poles
      RETURN
#endif

      TOTAL_Z1 = 0.
      TOTAL_Z2 = 0.
      TOTAL_Z3 = 0.
      TOTAL_Z4 = 0.
      TOTAL_A1 = 0.
      TOTAL_A2 = 0.
      TOTAL_A3 = 0.
      TOTAL_A4 = 0.

      DO I = 1, IIPAR
         TOTAL_Z1 = TOTAL_Z1 + GET_AREA_M2(       1 ) * Z(I,      1)
         TOTAL_Z2 = TOTAL_Z2 + GET_AREA_M2(       2 ) * Z(I,      2)
         TOTAL_Z3 = TOTAL_Z3 + GET_AREA_M2( JJPAR-1 ) * Z(I,JJPAR-1)
         TOTAL_Z4 = TOTAL_Z4 + GET_AREA_M2(   JJPAR ) * Z(I,JJPAR  )
         TOTAL_A1 = TOTAL_A1 + GET_AREA_M2(       1 ) 
         TOTAL_A2 = TOTAL_A2 + GET_AREA_M2(       2 )
         TOTAL_A3 = TOTAL_A3 + GET_AREA_M2( JJPAR-1 )
         TOTAL_A4 = TOTAL_A4 + GET_AREA_M2(   JJPAR )
      ENDDO

      DO I = 1, IIPAR
         Z(I,      1) = (TOTAL_Z1 + TOTAL_Z2) / (TOTAL_A1 + TOTAL_A2)
         Z(I,      2) = Z(I,1)
         Z(I,JJPAR-1) = (TOTAL_Z3 + TOTAL_Z4) / (TOTAL_A3 + TOTAL_A4)
         Z(I,JJPAR  ) = Z(I,JJPAR-1)
      ENDDO

      ! Return to calling program
      END SUBROUTINE AVGPOLE

!------------------------------------------------------------------------------
      
      SUBROUTINE AIRQNT
!
!******************************************************************************
!  Subroutine AIRQNT calculates the volume [m^3 and cm^3], mass [kg], density,
!  [kg/m^3], and pressure thickness [hPa] of air for each grid box (I,J,L).  
!  The quantity (surface pressure - PTOP) [hPa] at each surface grid box (I,J)
!  is also computed. (bmy, 1/30/98, 3/11/03)
!
!  DAO met fields updated by AIRQNT:
!  ========================================================================
!  (1 ) BXHEIGHT (REAL*8 ) : Vertical extent of a grid box   [m       ]
!  (2 ) DELP     (REAL*8 ) : Delta-P extent  of a grid box   [mb      ]
!  (3 ) AIRVOL   (REAL*8 ) : Volume  of air  in a grid box   [m^3     ]
!  (4 ) AD       (REAL*8 ) : Mass    of air  in a grid box   [kg      ]
!  (5 ) AIRDEN   (REAL*8 ) : Density of air  in a grid box   [kg/m^3  ]
!
!  NOTES:
!  (1 ) AIRQNT is written in Fixed-Form Fortran 90.  Use F90 syntax
!        for declarations etc. (bmy, 4/14/99)
!  (2 ) AIRQNT can now compute PW from PS (if LMAKEPW=T) or PS from PW.
!  (3 ) AIRQNT should also be called after TPCORE, since TPCORE changes
!        the PW values.  AIRQNT must then be called to compute the post-TPCORE
!        values of AD, BXHEIGHT, AIRVOL, and AIRDEN.
!  (4 ) The AIRDEN and DELP arrays are now dimensioned as (LLPAR,IIPAR,JJPAR) 
!        for better efficiency when processing a whole (I,J) column layer by 
!        layer.  In FORTRAN, the best efficiency is obtained when the leftmost 
!        array index corresponds to the innermost loop.
!  (5 ) Remove PTOP from the arg list.  PTOP is now a parameter in 
!      "CMN_SIZE".  Also updated comments. (bmy, 2/22/00)
!  (6 ) Replace IM, JM, LM with IIPAR, JJPAR, LLPAR as loop boundaries.
!        This ensures that all quantities get defined up to the top of
!        the atmosphere. (bmy, 6/15/00)
!  (7 ) Added to "dao_mod.f" (bmy, 6/26/00)
!  (8 ) Updated comments (bmy, 4/4/01)
!  (9 ) P(IREF,JREF) is now P(I,J).  T(IREF,JREF,L) is now T(I,J,L).  Also
!        removed LM from the arg list, it is obsolete.  Also updated
!        comments. (bmy, 9/26/01)
!  (10) Remove PW -- it is now obsolete.  Also make PW a local variable,
!        we need to preserve the way it computes P so as to avoid numerical
!        drift. (bmy, 10/4/01)
!  (11) Removed obsolete code from 9/01 and 10/01 (bmy, 10/23/01)
!  (12) Removed LMAKEPW from arg list.  Added parallel DO loops (bmy, 11/15/01)
!  (13) Removed obsolete code from 11/01 (bmy, 1/9/02)
!  (14) Now rename G_SIGE to SIGE, and dimension it (1:LLPAR+1).  Updated
!        comments, cosmetic changes. (bmy, 4/4/02)
!  (15) Removed obsolete, commented-out code (bmy, 6/25/02)
!  (16) Removed PS, P, SIGE from the arg list for hybrid grid.  Now reference
!        routines GET_PEDGE and GET_BP from "pressure_mod.f".  Removed 
!        obsolete, commented-out code. (dsa, bdf, bmy, 8/27/02)
!  (17) Now only pass DXYP via the arg list -- the other arguments are actually
!        are already contained within "dao_mod.f" (bmy, 11/15/02)
!  (18) Now replace DXYP(JREF) with routine GET_AREA_M2 of "grid_mod.f".
!        (bmy, 3/11/03)
!  (19) Now move computation of DELP into main loop.  Also remove P, LOGP,
!        JREF, DSIG variables -- these are obsolete for fvDAS.  (bmy, 6/19/03)
!******************************************************************************
!    
      ! References to F90 modules
      USE GRID_MOD,     ONLY : GET_AREA_M2
      USE PRESSURE_MOD, ONLY : GET_BP, GET_PEDGE

#     include "CMN_SIZE"  ! Size parameters
#     include "CMN_GCTM"  ! Physical constants

      ! Local variables
      INTEGER             :: I,  J,  L
      REAL*8              :: P1, P2, AREA_M2

      !=================================================================
      ! AIRQNT begins here! 
      !=================================================================
!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED )
!$OMP+PRIVATE( I, J, L, AREA_M2, P1, P2 )
      DO L = 1, LLPAR
      DO J = 1, JJPAR

         ! Grid box surface area [m2]
         AREA_M2 = GET_AREA_M2( J )

         DO I = 1, IIPAR
               
            ! Pressure at bottom edge of grid box [hPa]
            P1          = GET_PEDGE(I,J,L)

            ! Pressure at top edge of grid box [hPa]
            P2          = GET_PEDGE(I,J,L+1)

            ! Pressure difference between top & bottom edges [hPa]
            DELP(L,I,J) = P1 - P2

            !===========================================================
            ! BXHEIGHT is the height (Delta-Z) of grid box (I,J,L) 
            ! in meters. 
            !
            ! The formula for BXHEIGHT is just the hydrostatic eqn.  
            ! Rd = 287 J/K/kg is the value for the ideal gas constant
            ! R for air (M.W = 0.02897 kg/mol),  or 
            ! Rd = 8.31 J/(mol*K) / 0.02897 kg/mol. 
            !===========================================================
            BXHEIGHT(I,J,L) = Rdg0 * T(I,J,L) * LOG( P1 / P2 )

            !===========================================================
            ! AIRVOL is the volume of grid box (I,J,L) in meters^3
            !
            ! AREA_M2 is the Delta-X * Delta-Y surface area of grid
            ! boxes (I,J,L=1), that is, at the earth's surface.
            !
            ! Since the thickness of the atmosphere is much smaller 
            ! than the radius of the earth, we can make the "thin 
            ! atmosphere" approximation, namely:
            !
            !               (Rearth + h) ~ Rearth
            !
            ! Therefore, the Delta-X * Delta-Y surface area of grid
            ! boxes that are above the earth's surface will be 
            ! approx. the same as AREA_M2.  Thus we are justified 
            ! in using AREA_M2 for grid boxes (I, J, L > 1)
            !===========================================================
            AIRVOL(I,J,L) = BXHEIGHT(I,J,L) * AREA_M2

            !===========================================================
            ! AD = (dry) mass of air in grid box (I,J,L) in kg, 
            ! given by:        
            !
            !  Mass    Pressure        100      1        Surface area 
            !        = difference   *  ---  *  ---   *   of grid box 
            !          in grid box      1       g          AREA_M2
            !
            !   kg         mb          Pa      s^2           m^2
            !  ----  =    ----      * ----  * -----  *      -----
            !    1          1          mb       m             1
            !===========================================================
            AD(I,J,L) = DELP(L,I,J) * G0_100 * AREA_M2

            !===========================================================
            ! AIRDEN = density of air (AD / AIRVOL) in kg / m^3 
            !===========================================================
            AIRDEN(L,I,J) = AD(I,J,L) / AIRVOL(I,J,L)
         ENDDO
      ENDDO
      ENDDO
!$OMP END PARALLEL DO

      ! Return to calling program
      END SUBROUTINE AIRQNT

!------------------------------------------------------------------------------

      SUBROUTINE INTERP( NTIME0, NTIME1, NTDT )
!
!******************************************************************************
!  Subroutine INTERP linearly interpolates GEOS-CHEM I-6 fields (winds, 
!  surface pressure, temperature, surface albedo, specific humidity) to the 
!  current dynamic timestep. (bdf, bmy, 1/30/98, 6/19/03)
!
!  Arguments as Input:
!  ============================================================================
!  (1 ) NTIME0 (INTEGER) : elapsed time [s] at the start of the 6-hr timestep. 
!  (2 ) NTIME1 (INTEGER) : elapsed time [s] at current time
!  (3 ) NTDT   (INTEGER) : length of dynamic timestep [s]
!
!  NOTES:
!  (1 ) INTERP is written in Fixed-Form Fortran 90.
!  (2 ) Subtract PINT from PSC since the only subroutine that uses PSC
!        is TPCORE.  This prevents having to subtract and add PINT to PSC
!        before and after each call of TPCORE.
!  (3 ) Pass the Harvard CTM temperature variable T(IGCMPAR,JGCMPAR,LGCMPAR)
!        to INTERP via the argument list (instead of including file CMN).
!        It is computationally inefficient to keep two large arrays for
!        the same quantity.  Use the proper window offsets with T.
!  (4 ) Added to "dao_mod.f" (bmy, 6/26/00)
!  (5 ) Updated comments (bmy, 4/4/01)
!  (6 ) Replaced {IJL}GCMPAR w/ IIPAR,JJPAR,LLPAR.  Also now use parallel
!        DO-loop for interpolation.  Updated comments. (bmy, 9/26/01)
!  (7 ) Removed obsolete code from 9/01 (bmy, 10/23/01)
!  (8 ) Add PSC2 as the surface pressure at the end of the dynamic timestep.
!        This needs to be passed to TPCORE and AIRQNT so that the mixing ratio
!        can be converted to mass properly.  Removed PINT from the arg list,
!        since we don't need it anymore.  Also updated comments and made
!        some cosmetic changes.  (bmy, 3/27/02)
!  (9 ) Removed obsolete, commented-out code (bmy, 6/25/02)
!  (10) Eliminated PS, PSC from the arg list, for floating-pressure fix.
!        (dsa, bdf, bmy, 8/27/02)
!  (11) Met field arrays are module variables, so we don't need to pass them
!        as arguments. (bmy, 11/20/02)
!  (12) Removed NDT from the arg list since that is always 21600.  For GEOS-4
!        met fields, only interpolate PSC2; the other fields are 6-h averages.
!        Eliminate TC variable, it's obsolete.  Now use double precision to
!        compute TM and TC2 values.  Renamed NTIME to NTIME1 and NTIME1 to
!        NTIME0.  Updated comments. (bmy, 6/19/03)
!******************************************************************************
!     
#     include "CMN_SIZE"   ! Size parameters

      ! Arguments
      INTEGER, INTENT(IN)  :: NTIME0, NTIME1, NTDT  

      ! Local variables
      INTEGER              :: I,  J,  L
      REAL*8               :: D_NTIME0, D_NTIME1, D_NDT, D_NTDT, TM, TC2

      !=================================================================
      ! INTERP begins here!                                      
      !=================================================================

      ! Convert time variables from FLOAT to DBLE
      D_NTIME0 = DBLE( NTIME0 )
      D_NTIME1 = DBLE( NTIME1 )
      D_NTDT   = DBLE( NTDT   )
      D_NDT    = 21600d0

      ! Fraction of 6h timestep elapsed at mid point of this dyn timestep
      TM  = ( D_NTIME1 + D_NTDT/2d0 - D_NTIME0 ) / D_NDT
      
      ! Fraction of 6h timestep elapsed at the end of this dyn timestep
      TC2 = ( D_NTIME1 + D_NTDT     - D_NTIME0 ) / D_NDT 

#if   defined( GEOS_4 ) 

      !=================================================================
      ! GEOS-4: intepolate PSC2 (pressure at end of dyn timestep)
      !=================================================================
      DO J = 1, JJPAR
      DO I = 1, IIPAR
         PSC2(I,J) = PS1(I,J) + ( PS2(I,J) - PS1(I,J) ) * TC2 
      ENDDO
      ENDDO

#else

      !=================================================================
      ! GEOS-1, GEOS-S, GEOS-3: interp PSC2, UWND, VWND, ALBD, T, SPHU
      !=================================================================
!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED )
!$OMP+PRIVATE( I, J, L )
      DO L = 1, LLPAR
      DO J = 1, JJPAR
      DO I = 1, IIPAR
         
         ! 2D variables
         IF ( L == 1 ) THEN
            
            ! Pressures: at start, midpt, and end of dyn timestep
            PSC2(I,J) = PS1(I,J)   + ( PS2(I,J) - PS1(I,J) ) * TC2 

            ! Albedo: at midpt of dyn timestep
            ALBD(I,J) = ALBD1(I,J) + ( ALBD2(I,J) - ALBD1(I,J) ) * TM
  
         ENDIF
         
         ! 3D Variables: at midpt of dyn timestep
         UWND(I,J,L) = UWND1(I,J,L) + (UWND2(I,J,L) - UWND1(I,J,L)) * TM
         VWND(I,J,L) = VWND1(I,J,L) + (VWND2(I,J,L) - VWND1(I,J,L)) * TM
         SPHU(I,J,L) = SPHU1(I,J,L) + (SPHU2(I,J,L) - SPHU1(I,J,L)) * TM
         T(I,J,L)    = TMPU1(I,J,L) + (TMPU2(I,J,L) - TMPU1(I,J,L)) * TM
      ENDDO
      ENDDO
      ENDDO
!$OMP END PARALLEL DO

#endif

      ! Return to calling program
      END SUBROUTINE INTERP

!------------------------------------------------------------------------------

      FUNCTION IS_LAND( I, J ) RESULT ( LAND )
!
!******************************************************************************
!  Function IS_LAND returns TRUE if surface grid box (I,J) is a land 
!  or a land-ice box.  (bmy, 6/26/00, 6/18/03)
!
!  Arguments as Input
!  ===========================================================================
!  (1-2) I, J : Longitude and latitude indices of the grid box
!
!  NOTES:
!  (1 ) Now use ALBEDO field to determine land or land ice boxes for GEOS-3.
!        (bmy, 4/4/01)
!  (2 ) For 4x5 data, regridded albedo field can cause small inaccuracies
!        near the poles (bmy, 4/4/01)
!  (3 ) Add references to CMN_SIZE and CMN, so that we can use the JYEAR
!        variable to get the current year.  Also, for 1998, we need to compute
!        if is a land box or not from the surface albedo, since for this
!        year the LWI/SURFTYPE field is not given.  For other years than 1998,
!        we use LWI(I,J) < 50 as our land box criterion.  Deleted obsolete
!        code and updated comments.(mje, bmy, 1/9/02)
!  (4 ) Deleted GEOS-2 #ifdef statement.  GEOS-2 met fields never really
!        materialized, we use GEOS-3 instead. (bmy, 9/18/02)
!  (5 ) Now uses function GET_YEAR from "time_mod.f".  Removed reference
!        to CMN header file. (bmy, 3/11/03)
!  (6 ) Added code to determine land boxes for GEOS-4 (bmy, 6/18/03)
!******************************************************************************
!
      ! References to F90 modules
      USE TIME_MOD, ONLY : GET_YEAR

#     include "CMN_SIZE"   ! Size parameters

      ! Arguments
      INTEGER, INTENT(IN)  :: I, J

      ! Return variable
      LOGICAL              :: LAND

      !=================================================================
      ! IS_LAND begins here!
      !=================================================================
#if   defined( GEOS_1 ) || defined( GEOS_STRAT )

      ! For GEOS-1 or GEOS-STRAT -> LWI(I,J) = 2 is a land box
      !                             LWI(I,J) = 3 is a land ice box
      LAND = ( LWI(I,J) == 2 .or. LWI(I,J) == 3 )


#elif defined( GEOS_3 )

      IF ( GET_YEAR() == 1998 ) THEN
 
         ! GEOS-3 fields for 1998 don't have LWI/SURFTYPE flags,
         ! so we need to use albedo as a proxy for land coverage:
         ! Land    : 0.08 < ALBEDO < 0.04
         ! Land Ice: ALBEDO > 0.75
         LAND = ( ( ALBD(I,J) > 0.08d0 .and. ALBD(I,J) < 0.55d0 ) .OR. 
     &            ( ALBD(I,J) > 0. 75d0 ) )

      ELSE

         ! For other GEOS-3 years, LWI/SURFTYPE flags are included
         ! Land: LWI < 50
         LAND = ( LWI(I,J) < 50 )

      ENDIF

#elif defined( GEOS_4 )

      ! For GEOS-4: LWI=1 is a land box (bmy, 6/16/03)
      LAND = ( LWI(I,J) == 1 )

#endif

      ! Return to calling program
      END FUNCTION IS_LAND
      
!------------------------------------------------------------------------------

      FUNCTION IS_WATER( I, J ) RESULT ( WATER )
!
!******************************************************************************
!  Function IS_WATER returns TRUE if surface grid box (I,J) is an ocean 
!  or an ocean-ice box.  (bmy, 6/26/00, 6/18/03)
!
!  Arguments as Input
!  ===========================================================================
!  (1-2) I, J : Longitude and latitude indices of the grid box
!
!  NOTES:
!  (1 ) Now use ALBEDO field to determine water or water ice boxes for GEOS-3.
!        (bmy, 4/4/01)
!  (2 ) For 4x5 data, regridded albedo field can cause small inaccuracies
!        near the poles (bmy, 4/4/01)
!  (3 ) Add references to CMN_SIZE and CMN, so that we can use the JYEAR
!        variable to get the current year.  Also, for 1998, we need to compute
!        if is an ocean box or not from the surface albedo, since for this
!        year the LWI/SURFTYPE field is not given.  For other years than 1998,
!        we use LWI(I,J) >= 50 as our ocean box criterion.  Deleted obsolete
!        code and updated comments. (mje, bmy, 1/9/02)
!  (4 ) Deleted GEOS-2 #ifdef statement.  GEOS-2 met fields never really
!        materialized, we use GEOS-3 instead. (bmy, 9/18/02)
!  (5 ) Now uses function GET_YEAR from "time_mod.f".  Removed reference
!        to CMN header file. (bmy, 3/11/03)
!  (6 ) Added code to determine water boxes for GEOS-4 (bmy, 6/18/03)
!******************************************************************************
!
      ! References to F90 modules
      USE TIME_MOD, ONLY : GET_YEAR

#     include "CMN_SIZE"   ! Size parameters

      ! Arguments
      INTEGER, INTENT(IN)  :: I, J

      ! Return variable
      LOGICAL              :: WATER

      !=================================================================
      ! IS_WATER begins here!
      !=================================================================
#if   defined( GEOS_1 ) || defined( GEOS_STRAT )

      ! For GEOS-1 or GEOS-STRAT -> LWI(I,J) = 1 is an ocean box
      !                             LWI(I,J) = 4 is an ocean ice box
      WATER = ( LWI(I,J) == 1 .or. LWI(I,J) == 4 )

#elif defined( GEOS_3 )
      
      IF ( GET_YEAR() == 1998 ) THEN

         ! GEOS-3 fields for 1998 don't have LWI/SURFTYPE flags,
         ! so we need to use albedo as a proxy for water coverage:
         ! Liquid Water : ALBEDO < 0.08
         ! Water Ice    : 0.5  < ALBEDO < 0.75
         WATER = ( ( ALBD(I,J) < 0.08d0 ) .OR. 
     &             ( ALBD(I,J) > 0.55d0 .and. ALBD(I,J) < 0.75d0 ) ) 

      ELSE

         ! For other GEOS-3 years, LWI/SURFTYPE flags are included
         ! Water: LWI >= 50 
         WATER = ( LWI(I,J) >= 50 )

      ENDIF

#elif defined( GEOS_4 )

      ! GEOS-4: LWI=0 is water; LWI=2 is sea ice 
      WATER = ( LWI(I,J) == 0 .or. LWI(I,J) == 2 )

#endif

      ! Return to calling program
      END FUNCTION IS_WATER

!------------------------------------------------------------------------------

      SUBROUTINE MAKE_AVGW
!
!******************************************************************************
!  Subroutine MAKE_AVGW converts DAO specific humidity SPHU to AVGW, which 
!  is the mixing ratio of water vapor. (bmy, 1/30/98, 11/15/02)
!
!  NOTES:      
!  (1 ) AVGW was originally indexed by (L,I,J).  Reorder the indexing to
!        (I,J,L) to take advantage of the way FORTRAN stores by columns.
!        An (L,I,J) ordering can lead to excessive disk swapping.
!  (2 ) Now dimension AVGW as (IIPAR,JJPAR,LLPAR).  Also use parallel
!        DO-loop to compute AVGW.  Updated comments. (bmy, 9/24/01)
!  (3 ) Removed obsolete code from 9/01 (bmy, 10/23/01)
!  (4 ) SPHU and AVGW are declared w/in "dao_mod.f", so we don't need to pass
!        these as arguments anymore (bmy, 11/15/02)
!******************************************************************************
!     
#     include "CMN_SIZE"  ! Size parameters
      
      ! Local Variables
      INTEGER             :: I, IREF, J, JREF, L      

      ! Conversion factor
      REAL*8, PARAMETER   :: HCONV = 28.97d-3 / 18.0d0 

      !=================================================================
      ! MAKE_AVGW begins here!
      !
      ! In the original Harvard/GISS/Irvine CTM subroutines, 
      !    AVGW = log10( mixing ratio of water vapor ).  
      !
      ! In order to avoid costly log and exponentiation operations, 
      ! redefine AVGW, so that AVGW is the actual mixing ratio of water 
      ! vapor, and not the log10 of the mixing ratio.
      !
      ! The conversion from SPHU [g H2O/kg air] to [v/v] mixing ratio is:
      !
      !   g H2O  | mol H2O  | 28.97e-3 kg air    mol H2O     vol H2O
      ! ---------+----------+---------------- = --------- = ---------
      !   kg air | 18 g H2O |    mol air         mol air     vol air
      !
      !      thus AVGW (V/V) = SPHU (g/kg) * HCONV, 
      !
      ! where HCONV = the conversion factor ( 28.97e-3 / 18.0 ), 
      ! which is defined as a parameter at the top of this routine.
      !=================================================================
!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED )
!$OMP+PRIVATE( I, J, L )
      DO L = 1, LLPAR
      DO J = 1, JJPAR
      DO I = 1, IIPAR
         AVGW(I,J,L) = HCONV * SPHU(I,J,L) 
      ENDDO
      ENDDO
      ENDDO
!$OMP END PARALLEL DO

      ! Return to calling program
      END SUBROUTINE MAKE_AVGW

!------------------------------------------------------------------------------

      SUBROUTINE MAKE_RH
!
!******************************************************************************
!  Subroutine MAKE_RH computes relative humidity from specific humidity and
!  temperature. (bmy, 10/13/99, 9/18/02)
!
!  Module variables used:
!  ===========================================================================
!  (1 ) SPHU (REAL*8) : Array containing 3-D specific humidity [g H2O/kg air]
!  (2 ) TMPU (REAL*8) : Array containing 3-D temperature field [K]
!  (3 ) RH   (REAL*8) : Output array for relative humidity     [%]
!
!  NOTES:
!  (1 ) Use F90 syntax for declarations, etc. 
!  (2 ) Cosmetic changes (bmy, 10/12/99)
!  (3 ) Now use GET_PCENTER from "pressure_mod.f" to compute the pressure
!        at the midpoint of grid box (I,J,L).  Updated comments, cosmetic
!        changes.  Added parallel DO-loops.  Remove reference to "CMN" 
!        header file.  Added to "dao_mod.f" (dsa, bdf, bmy, 8/27/02)
!  (4 ) Removed obsolete code from 8/02 (bmy, 9/18/02)
!  (5 ) Now remove SPHU, TMPU, RH from the arg list, since these are now
!        all contained w/in this dao_mod.f as module variables. (bmy, 9/23/02)
!******************************************************************************
!
      ! References to F90 modules
      USE PRESSURE_MOD, ONLY : GET_PCENTER

      IMPLICIT NONE

#     include "CMN_SIZE"  ! Size parameters

      ! Local variables
      REAL*8, PARAMETER   :: A =   23.5518d0
      REAL*8, PARAMETER   :: B = 2937.4d0
      REAL*8, PARAMETER   :: C =   -4.9283d0
      REAL*8              :: ESAT, SHMB, PRES, TEMP
      INTEGER             :: I, J, L

      !=================================================================
      ! MAKE_RH begins here!
      !=================================================================
!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED )
!$OMP+PRIVATE( I, J, L, PRES, TEMP, ESAT, SHMB )
      DO L = 1, LLPAR
      DO J = 1, JJPAR
      DO I = 1, IIPAR

         ! Pressure at midpoint of box (I,J,L)
         PRES = GET_PCENTER(I,J,L)

         ! Temperature at grid box (I,J,L)
         TEMP = T(I,J,L)

         ! Saturation water vapor pressure in mbar 
         ! (from NASA GTE PEM-Tropics handbook)
         ESAT = ( 10d0**( A - ( B / TEMP ) ) ) * ( TEMP**C )
            
         ! Specific humidity in mb
         SHMB = SPHU(I,J,L) * 1.6072d-3 * PRES
            
         ! Relative humidity as a percentage
         RH(I,J,L) = ( SHMB / ESAT ) * 100d0 

      ENDDO
      ENDDO
      ENDDO  
!$OMP END PARALLEL DO

      ! Return to calling program
      END SUBROUTINE MAKE_RH

!------------------------------------------------------------------------------

      SUBROUTINE MAKE_WIND10M( UWND, VWND, BXHEIGHT, Z0 )
!
!******************************************************************************
!  Subroutine MAKE_WIND10M (bmy, 3/17/99, 12/9/03) creates the wind speed 
!  at 10 meters altitude from GEOS-STRAT wind vectors at the center of the 
!  first sigma level.  This is necessary since GEOS-STRAT does not store 
!  U10M and V10M wind fields, as does GEOS-1.  
!
!  Arguments as input:
!  ==========================================================================
!  (1) UWND(IIPAR,JJPAR) : DAO U-wind for first sigma level ( m/s )
!  (2) VWND(IIPAR,JJPAR) : DAO V-wind for first sigma level ( m/s )
!  (3) Z0  (MAXIJ      ) : DAO roughness heights            ( m   )
!
!  Passed via common blocks
!  ==========================================================================
!  (1) BXHEIGHT(IIPAR,JJPAR,LLPAR) : Height of each grid box       ( m   )
!  (2) WIND_10M(IIPAR,JJPAR      ) : Resultant wind speed at 10 m  ( m/s )
!
!  NOTES:
!  (1 ) Cosmetic changes (bmy, 10/13/99, 4/19/00)
!  (2 ) Now check for NaN's.  Also bracket the body of this subroutine 
!        by an #if defined( GEOS_STRAT ) statement. (bmy, 4/27/00)
!  (3 ) Added BXHEIGHT to the argument list.  Also added this routine to 
!        "dao_mod.f"  (bmy, 6/23/00)
!  (4 ) Updated comments (bmy, 4/4/01)
!  (5 ) Now references routine CHECK_VALUE from "error_mod.f" (bmy, 7/16/01)
!  (6 ) Now make Z0 a 2-D array (bmy, 12/9/03)
!******************************************************************************
!
      ! References to F90 modules
      USE ERROR_MOD, ONLY : CHECK_VALUE

      IMPLICIT NONE

#     include "CMN_SIZE"  ! Size parameters  

      ! Arguments
      REAL*8, INTENT(IN) :: UWND(IIPAR,JJPAR)
      REAL*8, INTENT(IN) :: VWND(IIPAR,JJPAR)
      REAL*8, INTENT(IN) :: BXHEIGHT(IIPAR,JJPAR)
      REAL*8, INTENT(IN) :: Z0(IIPAR,JJPAR)

      ! Local variables
      REAL*8             :: WIND_50M, NUMER, DENOM
      INTEGER            :: I,        J,     IJLOOP

      !=================================================================
      ! MAKE_WIND10M begins here!!
      !
      ! For each surface grid box (I,J), compute the wind speed at 
      ! h(I,J) = BXHEIGHT(I,J,1) / 2.  This will be approx 50 m for 
      ! most grid boxes.
      !  
      ! Then knowing the wind speed at h, compute the wind speed 
      ! at 10 m, using the log law:
      !
      !           U( 10 m )       ln( 10 m / Z0 )
      !           ---------   =  ----------------
      !           U( h    )       ln(  h   / Z0 ) 
      !
      ! Where Z0 is the DAO roughness height in meters. 
      !=================================================================
#if   defined( GEOS_STRAT )
      IJLOOP = 0
      DO J = 1, JJPAR
      DO I = 1, IIPAR
          
         ! Wind speed at ~50 meters
         WIND_50M      = SQRT( UWND(I,J)**2 + VWND(I,J)**2 )

         ! Numerator and denominator of the log law expressions
         NUMER         = LOG( 10d0 / Z0(I,J) )  
         DENOM         = LOG( ( BXHEIGHT(I,J) / 2.0d0 ) / Z0(I,J) ) 

         ! Wind speed at 10 m
         WIND_10M(I,J) = WIND_50M * ( NUMER / DENOM )

         ! Now call CHECK_VALUE to make sure that WIND_10M
         ! is not a NaN or an infinity (bmy, 7/16/01)
         CALL CHECK_VALUE( WIND_10M(I,J), (/I,J,0,0/), 
     &                     'WIND_10M',    'at MAKE_WIND10m (dao_mod)' )
      ENDDO
      ENDDO
#endif

      ! Return to calling program
      END SUBROUTINE MAKE_WIND10M

!------------------------------------------------------------------------------

      SUBROUTINE COSSZA( JDAY, NHMSb, NSEC, SUNCOS )
!
!******************************************************************************
!  COSSZA computes the cosine of the zenith angle of the sun.  
!  (bmy, 1/21/98, 2/3/03)
!
!  Arguments as input:
!  ============================================================================
!  (1 ) JDAY   (INTEGER) : The current day of the year (0-365 or 0-366)
!  (2 ) NHMSb  (INTEGER) : HH/MM/SS at the start of the model run (e.g. 000000)
!  (3 ) NSEC   (INTEGER) : Time in seconds since the start of the model run
!
!  Arguments as output:
!  ===========================================================================
!  (1 ) SUNCOS (REAL*8 ) : 1D Array of cos(SZA) for each grid box (in radians)
!
!  NOTES:
!  (1 ) COSSZA is written in Fixed-Form Fortran 90.
!  (2 ) Use IMPLICIT NONE to declare all variables explicitly.                
!  (3 ) Use C-preprocessor #include statement to include CMN_SIZE, which 
!        has IIPAR, JJPAR, LLPAR, IGLOB, JGLOB, LGLOB. 
!  (4 ) Use IM and JM (in CMN_SIZE) as loop limits.
!  (5 ) Include Harvard CTM common blocks and rename variables where needed.  
!  (6 ) Use SUNCOS(MAXIJ) instead of a 2D array, in order for compatibility
!        with the Harvard CTM subroutines.  SUNCOS loops over J, then I.
!  (7 ) Added DO WHILE loops to reduce TIMLOC into the range 0h - 24h.
!  (8 ) Cosmetic changes.  Also use F90 declaration statements (bmy, 6/5/00)
!  (9 ) Added to "dao_mod.f".  Also updated comments. (bmy, 9/27/01)
!  (10) Replaced all instances of IM with IIPAR and JM with JJPAR, in order
!        to prevent namespace confusion for the new TPCORE (bmy, 6/25/02)
!  (11) Deleted obsolete code from 6/02 (bmy, 8/21/02)
!  (12) Removed RLAT and XLON from the arg list.  Now compute these using 
!        functions from "grid_mod.f" (bmy, 2/3/03)
!******************************************************************************
!
      ! References to F90 modules
      USE GRID_MOD, ONLY : GET_XMID, GET_YMID_R

#     include "CMN_SIZE"
#     include "CMN_GCTM"


      ! Arguments
      INTEGER, INTENT(IN)  :: JDAY, NHMSb, NSEC
      REAL*8,  INTENT(OUT) :: SUNCOS(MAXIJ)

      ! Local variables
      INTEGER              :: I, IJLOOP, J, LHR0

      REAL*8               :: A0, A1, A2, A3, B1, B2, B3
      REAL*8               :: R, AHR, DEC, TIMLOC, XLON, YMID_R 

      !=================================================================
      ! COSSZA begins here!   
      !=================================================================

      !  Solar declination angle (low precision formula, good enough for us):
      A0 = 0.006918
      A1 = 0.399912
      A2 = 0.006758
      A3 = 0.002697
      B1 = 0.070257
      B2 = 0.000907
      B3 = 0.000148
      R  = 2.* PI * float(JDAY-1) / 365.

      DEC = A0 - A1*cos(  R) + B1*sin(  R)
     &         - A2*cos(2*R) + B2*sin(2*R)
     &         - A3*cos(3*R) + B3*sin(3*R)

      LHR0 = int(float(NHMSb)/10000.)

      !=================================================================
      ! Loop over J first, then I, for compatibility w/ Harvard code
      !=================================================================
      IJLOOP = 0

      ! Loop over latitude
      DO J = 1, JJPAR

         ! Latitude of grid box [radians]
         YMID_R = GET_YMID_R( J )

         ! Loop over longitude
         DO I = 1, IIPAR

            ! 1-D grid box index for SUNCOS
            IJLOOP = IJLOOP + 1

            !===========================================================
            ! TIMLOC = Local Time in Hours                   
            !
            ! Hour angle (AHR) is a function of longitude.  AHR is 
            ! zero at solar noon, and increases by 15 deg for every 
            ! hour before or after solar noon.  
            !
            ! Hour angle can be thought of as the time in hours since 
            ! the sun last passed the meridian (i.e. the time since the
            ! last local noon).
            !
            ! If TIMLOC is greater then 24 hours, reduce it to the 
            ! range of 0 - 24h.
            !
            ! The DO WHILE loops are legal in both F90 and in most 
            ! versions of F77.            
            !===========================================================
            
            ! Grid box longitude [degrees]
            XLON   = GET_XMID( I )
            
            ! Local time [hours]
            TIMLOC = float(LHR0) + float(NSEC)/3600.0 + XLON/15.0
            
            DO WHILE (TIMLOC .lt. 0)
               TIMLOC = TIMLOC + 24.0
            ENDDO
            
            DO WHILE (TIMLOC .gt. 24.0)
               TIMLOC = TIMLOC - 24.0
            ENDDO
            
            AHR = abs(TIMLOC - 12.) * 15.0 * PI_180
            
            !===========================================================
            ! The cosine of the solar zenith angle (SZA) is given by:
            !     
            !  cos(SZA) = sin(LAT)*sin(DEC) + cos(LAT)*cos(DEC)*cos(AHR) 
            !                   
            ! where LAT = the latitude angle, 
            !       DEC = the solar declination angle,  
            !       AHR = the hour angle, all in radians. 
            !
            ! If SUNCOS < 0, then the sun is below the horizon, and 
            ! therefore does not contribute to any solar heating.  
            !===========================================================
               
            ! Compute Cos(SZA)
            SUNCOS(IJLOOP) = sin(YMID_R) * sin(DEC) +
     &                       cos(YMID_R) * cos(DEC) * cos(AHR)
         ENDDO ! I
      ENDDO    ! J

      ! Return to calling program 
      END SUBROUTINE COSSZA

!------------------------------------------------------------------------------

      SUBROUTINE CONVERT_UNITS( IFLAG, NTRACE, TCVV, AD, STT ) 
!
!******************************************************************************
!  Subroutine CONVERT_UNITS converts the units of STT from [kg] to [v/v]
!  mixing ratio, or vice versa.  (bmy, 6/15/98, 10/15/02)
!
!  Arguments as Input:
!  ======================================================================
!  (1 ) IFLAG  (INTEGER) : =1 then convert from [kg ] --> [v/v]
!                          =2 then convert from [v/v] --> [kg ]
!  (2 ) NTRACE (INTEGER) : 
!  (3 ) TCVV   (REAL*8 ) : Array containing [Air MW / Tracer MW] for tracers
!  (4 ) AD     (REAL*8 ) : Array containing grid box air masses
!
!  Arguments as Input/Output:
!  ======================================================================
!  (5 ) STT    (REAL*8 ) : Array containing tracer conc. [kg] or [v/v]
!
!  NOTES:
!  (1 ) CONVERT_UNITS is written in Fixed-Form Fortran 90.
!  (2 ) Cosmetic changes, updated comments (bmy, 4/19/00)
!  (3 ) Now use SELECT CASE statement.  Also added parallel DO-loops
!        with the new Open-MP compiler directives. (bmy, 4/27/00)
!  (4 ) Bundled into "dao_mod.f".  Now pass NTRACE, TCVV, AD, STT as args.
!        Now use explicit DO-loops for I-J-L w/in parallel loops.  Updated
!        comments, cosmetic changes. (bmy, 3/29/02)
!  (5 ) Removed obsolete, commented-out code.  Also now use F90 intrinsic
!        REPEAT to write a line of "="'s to the screen. (bmy, 6/25/02)
!  (6 ) Updated comments.  Now reference ERROR_STOP from "error_mod.f" 
!        (bmy, 10/15/02)
!******************************************************************************
! 
      ! References to F90 modules
      USE ERROR_MOD, ONLY : ERROR_STOP

#     include "CMN_SIZE"     ! Size parameters

      ! Arguments
      INTEGER, INTENT(IN)    :: IFLAG
      INTEGER, INTENT(IN)    :: NTRACE 
      REAL*8,  INTENT(IN)    :: TCVV(NTRACE)
      REAL*8,  INTENT(IN)    :: AD(IIPAR,JJPAR,LLPAR)
      REAL*8,  INTENT(INOUT) :: STT(IIPAR,JJPAR,LLPAR,NTRACE)

      ! Local Variables
      INTEGER                :: I, J, L, N

      !=================================================================
      ! CONVERT_UNITS begins here!
      !
      ! Most of the GEOS-CHEM subroutines require the tracer array 
      ! STT to be in units of [kg].  However, the cloud convection 
      ! (NFCLDMX), boundaryk layer mixing (TURBDAY), diffusion (DIFFUSE), 
      ! and transport (TPCORE) routines require STT to be in volume 
      ! mixing ratio [v/v].  
      !
      ! Therefore, before calling NFCLDMX, TURBDAY, DIFFUSE, or TPCORE, 
      ! call subroutine CONVERT_UNITS to convert STT from [kg] to [v/v].  
      !
      ! Also call CONVERT_UNITS again after calling NFCLDMX, TURBDAY, 
      ! DIFFUSE, or TPCORE to convert back from [v/v] to [kg].  
      !=================================================================
      SELECT CASE ( IFLAG )

         !==============================================================
         ! IFLAG = 1: Convert from [kg] -> [v/v] 
         !
         !  The conversion is as follows:
         !
         !   kg tracer(N)       1        Air mol wt     
         !   -----------  * -------- *  -------------   
         !        1          kg air     tracer mol wt   
         !
         !       moles tracer     volume tracer
         !   =   ------------  =  -------------
         !        moles air        volume air
         !
         ! Since the volume of a gas depends on the number of moles.
         ! Therefore, with:
         !
         !  TCMASS(N) = mol. wt. of tracer (AMU)
         !  TCVV(N)   = 28.97 / TCMASS(N)
         !            = mol. wt. of air (AMU) / mol. wt. of tracer (AMU)
         !  AD(I,J,L) = mass of air (kg) in grid box (I,J,L)
         !     
         ! the conversion is:
         ! 
         !  STT(I,J,L,N) [kg] * TCVV(N) / AD(I,J,L) = STT(I,J,L,N) [v/v]
         !==============================================================
         CASE ( 1 )

!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED ) 
!$OMP+PRIVATE( I, J, L, N ) 
            DO N = 1, NTRACE
            DO L = 1, LLPAR
            DO J = 1, JJPAR
            DO I = 1, IIPAR
               STT(I,J,L,N) = STT(I,J,L,N) * TCVV(N) / AD(I,J,L)
            ENDDO
            ENDDO
            ENDDO
            ENDDO
!$OMP END PARALLEL DO

         !==============================================================
         ! IFLAG = 2: Convert from [v/v] -> [kg] 
         !
         ! From the above discussion, the reverse unit conversion 
         ! is given by:
         !
         !  STT(I,J,L,N) [v/v] * AD(I,J,L) / TCVV(N) = STT(I,J,L,N) [kg]
         !==============================================================
         CASE ( 2 )

!$OMP PARALLEL DO 
!$OMP+DEFAULT( SHARED ) 
!$OMP+PRIVATE( I, J, L, N )
            DO N = 1, NTRACE
            DO L = 1, LLPAR
            DO J = 1, JJPAR
            DO I = 1, IIPAR
               STT(I,J,L,N) = STT(I,J,L,N) * AD(I,J,L) / TCVV(N)
            ENDDO     
            ENDDO
            ENDDO
            ENDDO
!$OMP END PARALLEL DO

         !==============================================================
         ! Otherwise halt with an error message
         !==============================================================
         CASE DEFAULT
            CALL ERROR_STOP( 'Invalid IFLAG value (must be 1 or 2)!', 
     &                       'CONVERT_UNITS (dao_mod.f)' )
      END SELECT

      ! Return to calling program
      END SUBROUTINE CONVERT_UNITS

!------------------------------------------------------------------------------

      SUBROUTINE INIT_DAO
!
!******************************************************************************
!  Subroutine INIT_DAO allocates memory for all allocatable module arrays. 
!  (bmy, 6/26/00, 12/9/03)
!
!  NOTES:
!  (1 ) Now allocate AVGW for either NSRCX == 3 or NSRCX == 5 (bmy, 9/24/01)
!  (2 ) Removed obsolete code from 9/01 (bmy, 10/23/01)
!  (3 ) Add PSC2 array for TPCORE mixing ratio fix.   (bmy, 3/27/02)
!  (4 ) Elimintated PS, PSC arrays for floating-pressure fix.
!        (dsa, bdf, bmy, 8/20/02)
!  (5 ) Added AD, BXHEIGHT, T to "dao_mod.f" as allocatable arrays, to remove
!        historical baggage and centralize variables.  Also remove GEOS_2 
!        flag from C-preprocessor statements.  Also allocate RH array
!        but only if we are doing a sulfate simulation.  Now references
!        ALLOC_ERR from "error_mod.f" (bmy, 10/15/02)
!  (6 ) Now allocate PHIS array (bmy, 3/11/03)
!  (7 ) Now allocate SUNCOSB array for SMVGEAR II.  Also removed KZZ array,
!        that is now obsolete. (bdf, bmy, 4/28/03)
!  (8 ) Now order all arrays in alphabetical order.  Also added new fields
!        for GEOS-4/fvDAS: HKBETA, HKETA, ZMEU, ZMMD, ZMMU, TSKIN, PARDF,
!        and PARDR. (bmy, 6/25/03)
!  (9 ) Now allocate CLDFRC, RADLWG, RADSWG, SNOW arrays.  USTAR, CLDFRC,
!        and Z0 and RADSWG are now 2-D arrays. (bmy, 12/9/03)
!******************************************************************************
!
      ! References to F90 modules
      USE ERROR_MOD, ONLY : ALLOC_ERR

#     include "CMN_SIZE"   ! IIPAR, JJPAR, LLPAR
#     include "CMN"        ! NSRCX
#     include "CMN_SETUP"  ! LWETD, LDRYD

      ! Local variables
      INTEGER :: AS

      !=================================================================
      ! INIT_DAO begins here!
      !=================================================================

      ALLOCATE( AD( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'AD' )
      AD = 0d0

      ALLOCATE( AIRDEN( LLPAR, IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'AIRDEN' )
      AIRDEN = 0d0

      ALLOCATE( AIRVOL( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'AIRVOL' )
      AIRVOL = 0d0
      
#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) || defined( GEOS_3 )

      ! ALBD1 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( ALBD1( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'ALBD1' )
      ALBD1 = 0d0

      ! ALBD2 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( ALBD2( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'ALBD2' )
      ALBD2 = 0d0

#endif

      ALLOCATE( ALBD( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'ALBD' )
      ALBD = 0d0

      ! AVGW is only used for NOx-Ox-HC, HCN, or CO-OH chem
      IF ( NSRCX == 3 .or. NSRCX == 4 .or. NSRCX == 5 ) THEN
         ALLOCATE( AVGW( IIPAR, JJPAR, LLPAR ), STAT=AS )
         IF ( AS /= 0 ) CALL ALLOC_ERR( 'AVGW' )
         AVGW = 0d0
      ENDIF

      ALLOCATE( BXHEIGHT( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'BXHEIGHT' )
      BXHEIGHT = 0d0

      ALLOCATE( CLDF( LLPAR, IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'CLDF' )
      CLDF = 0d0

      ! Added CLDFRC array (bmy, 12/9/03)
      ALLOCATE( CLDFRC( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'CLDFRC' )
      CLDFRC = 0d0

#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) || defined( GEOS_3 )

      ! CLDMAS is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( CLDMAS( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'CLDMAS' )
      CLDMAS = 0d0

#endif

      ALLOCATE( CLDTOPS( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'CLDTOPS' )
      CLDTOPS = 0

#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) 

      ! CLMOSW is only defined for GEOS-1 and GEOS-STRAT data sets
      ALLOCATE( CLMOSW( LLPAR, IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'CLMOSW' )
      CLMOSW = 0d0

      ! CLROSW is only defined for GEOS-1 and GEOS-STRAT data sets
      ALLOCATE( CLROSW( LLPAR, IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'CLROSW' )
      CLROSW = 0d0

#endif

      ALLOCATE( DELP( LLPAR, IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'DELP' )
      DELP = 0d0

#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) || defined( GEOS_3 )

      ! DTRAIN is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( DTRAIN( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'DTRAIN' )
      DTRAIN = 0d0

#endif

#if   defined( GEOS_4 )

      ! GWETTOP is only defined for GEOS-4
      ALLOCATE( GWETTOP( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'GWETTOP' )
      GWETTOP = 0d0

#endif

      ALLOCATE( HFLUX( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'HFLUX' )
      HFLUX = 0d0

#if   defined( GEOS_4 ) 

      ! HKBETA is only defined for GEOS-4 
      ALLOCATE( HKBETA( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'HKBETA' )
      HKBETA = 0d0

      ! HKETA is only defined for GEOS-4
      ALLOCATE( HKETA( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'HKETA' )
      HKETA = 0d0

#endif

      ALLOCATE( LWI( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'LWI' )
      LWI = 0

      ALLOCATE( MOISTQ( LLPAR, IIPAR, JJPAR ), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'MOISTQ' )
      MOISTQ = 0d0

#if   defined( GEOS_3 ) || defined( GEOS_4 )

      ! OPTDEP is only defined for GEOS-3 and GEOS-4
      ALLOCATE( OPTDEP( LLPAR, IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'OPTDEP' )
      OPTDEP = 0d0

#endif

      ALLOCATE( OPTD( LLPAR, IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'OPTD' )
      OPTD = 0d0

#if   defined( GEOS_3 ) || defined( GEOS_4 ) 

      ! PARDF is only defined for GEOS_3 or GEOS-4
      ALLOCATE( PARDF( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PARDF' )
      PARDF = 0d0

      ! PARDR is only defined for GEOS-3 or GEOS-4
      ALLOCATE( PARDR( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PARDR' )
      PARDR = 0d0

#endif

      ALLOCATE( PBL( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PBL' )
      PBL = 0d0

      ALLOCATE( PHIS( IIPAR, JJPAR ), STAT=AS )  
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PHIS' )
      PHIS = 0d0

      ALLOCATE( PREACC( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PREACC' )
      PREACC = 0d0

      ALLOCATE( PRECON( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PRECON' )
      PRECON = 0d0
   
      ALLOCATE( PS1( IIPAR, JJPAR ), STAT=AS )  
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PS1' )
      PS1 = 0d0

      ALLOCATE( PS2( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PS2' )
      PS2 = 0d0

      ALLOCATE( PSC2( IIPAR, JJPAR ), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'PSC2' )
      PSC2 = 0d0

      ! Only allocate RH for coupled sulfate-aerosol or 
      ! standalone sulfate chemistry (bmy, 9/23/02)
      IF ( LCHEM .and. ( NSRCX == 3 .or. NSRCX == 10 )  ) THEN 
         ALLOCATE( RH( IIPAR, JJPAR, LLPAR ), STAT=AS )
         IF ( AS /= 0 ) CALL ALLOC_ERR( 'RH' )
         RH = 0d0
      ENDIF

      ! Added RADSWG (bmy, 12/9/03)
      ALLOCATE( RADSWG( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'RADSWG' )
      RADSWG = 0d0

#if   defined( GEOS_3 ) || defined( GEOS_4 )

      ! SLP is only defined for GEOS-3 and GEOS-4
      ALLOCATE( SLP( IIPAR, JJPAR ), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'SLP' )
      SLP = 0d0      

#endif

#if   defined( GEOS_4 ) 

      ! RADLWG is only defined for GEOS-4 (bmy, 12/9/03)
      ALLOCATE( RADLWG( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'RADLWG' )
      RADLWG = 0d0

      ! SNOW is only defined for GEOS-4 (bmy, 12/9/03)
      ALLOCATE( SNOW( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'SNOW' )
      SNOW = 0d0

#endif
   
#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) || defined( GEOS_3 )

      ! SPHU1 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( SPHU1( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'SPHU1' )
      SPHU1 = 0d0

      ! SPHU2 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( SPHU2( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'SPHU2' )
      SPHU2 = 0d0

#endif

      ALLOCATE( SPHU( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'SPHU' )
      SPHU = 0d0

      ALLOCATE( SUNCOS( MAXIJ ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'SUNCOS' )
      SUNCOS = 0d0

      ! Only allocate SUNCOSB for a full-chemistry run (bdf, bmy, 4/1/03)
      IF ( LCHEM .and. NSRCX == 3 ) THEN
         ALLOCATE( SUNCOSB( MAXIJ ), STAT=AS )
         IF ( AS /= 0 ) CALL ALLOC_ERR( 'SUNCOSB' )
         SUNCOSB = 0d0
      ENDIF

      ALLOCATE( T( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'T' )
      T = 0d0

#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) || defined( GEOS_3 )

      ! TMPU is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( TMPU1( IIPAR, JJPAR, LLPAR ), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'TMPU1' )
      TMPU1 = 0d0

      ! TMPU2 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( TMPU2( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'TMPU2' )
      TMPU2 = 0d0

#endif

#if   defined( GEOS_3 ) || defined ( GEOS_4 ) 

      ! TROPP is only defined for GEOS-3 or GEOS-4
      ALLOCATE( TROPP( IIPAR, JJPAR ), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'TROPP' )
      TROPP = 0d0

#endif

      ALLOCATE( TS( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'TS' )
      TS = 0d0

#if   defined( GEOS_4 )

      ! TSKIN is only defined for GEOS-4
      ALLOCATE( TSKIN( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'TSKIN' )
      TSKIN = 0d0

#endif

      ALLOCATE( U10M( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'U10M' )
      U10M = 0d0

      ALLOCATE( USTAR( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'USTAR' )
      USTAR = 0d0

#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) || defined( GEOS_3 )

      ! UWND1 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( UWND1( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'UWND1' )
      UWND1 = 0d0

      ! UWND2 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( UWND2( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'UWND2' )
      UWND2 = 0d0

#endif

      ALLOCATE( UWND( IIPAR, JJPAR, LLPAR), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'UWND' )
      UWND = 0d0

      ALLOCATE( V10M( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'V10M' )
      V10M = 0d0

#if   defined( GEOS_1 ) || defined( GEOS_STRAT ) || defined( GEOS_3 )

      ! VWND1 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( VWND1( IIPAR, JJPAR, LLPAR ), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'VWND1' )
      VWND1 = 0d0

      ! VWND2 is only defined for GEOS-1, GEOS-S, GEOS-3
      ALLOCATE( VWND2( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'VWND2' )
      VWND2 = 0d0

#endif

      ALLOCATE( VWND( IIPAR, JJPAR, LLPAR ), STAT=AS ) 
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'VWND' )
      VWND = 0d0

#if   defined( GEOS_STRAT )

      ! WIND_10M is only defined for GEOS-STRAT
      ALLOCATE( WIND_10M( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'WIND_10M' )
      WIND_10M = 0d0

#endif

      ALLOCATE( Z0( IIPAR, JJPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'Z0' )
      Z0 = 0d0

#if   defined( GEOS_4 )

      ! ZMEU is only defined for GEOS-4
      ALLOCATE( ZMEU( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'ZMEU' )
      ZMEU = 0d0

      ! ZMMD is only defined for GEOS-4
      ALLOCATE( ZMMD( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'ZMMD' )
      ZMMD = 0d0

      ! ZMMU is only defined for GEOS-4
      ALLOCATE( ZMMU( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'ZMMU' )
      ZMMU = 0d0

#endif

      ! Return to calling program
      END SUBROUTINE INIT_DAO

!------------------------------------------------------------------------------

      SUBROUTINE CLEANUP_DAO
!
!******************************************************************************
!  Subroutine CLEANUP_DAO deallocates all met field arrays. 
!  (bmy, 6/26/00, 12/9/03)
! 
!  NOTES:
!  (1 ) Now deallocate SLP met field for GEOS-3 (bmy, 10/10/00)
!  (2 ) Now deallocate OPTDEP met field for GEOS-3 (bmy, 8/15/01)
!  (3 ) Now deallocate AVGW (bmy, 9/24/01)
!  (4 ) Remove TAUCLD deallocation -- it's obsolete (bmy, 10/23/01)
!  (5 ) Add call to deallocate PSC2 array (bmy, 3/27/02)
!  (6 ) Elimintated PS, PSC arrays for floating-pressure fix.
!        (dsa, bdf, bmy, 8/20/02)
!  (7 ) Now deallocate AD, BXHEIGHT, and T arrays (bmy, 9/18/02)
!  (8 ) Now deallocate PHIS array (bmy, 3/11/03)
!  (9 ) Now deallocate SUNCOSB array.  Remove reference to KZZ, since
!        that is now obsolete. (bmy, 4/28/03)
!  (10) Now list all arrays in order.  Now also deallocate new arrays
!        for GEOS-4/fvDAS. (bmy, 6/25/03)
!  (11) Now deallocate CLDFRC, RADLWG, RADSWG, SNOW arrays (bmy, 12/9/03)
!******************************************************************************
!
      !=================================================================
      ! CLEANUP_DAO begins here!
      !=================================================================
      IF ( ALLOCATED( AD       ) ) DEALLOCATE( AD       ) 
      IF ( ALLOCATED( AIRDEN   ) ) DEALLOCATE( AIRDEN   )
      IF ( ALLOCATED( AIRVOL   ) ) DEALLOCATE( AIRVOL   )
      IF ( ALLOCATED( ALBD1    ) ) DEALLOCATE( ALBD1    )
      IF ( ALLOCATED( ALBD2    ) ) DEALLOCATE( ALBD2    )
      IF ( ALLOCATED( ALBD     ) ) DEALLOCATE( ALBD     )
      IF ( ALLOCATED( AVGW     ) ) DEALLOCATE( AVGW     )
      IF ( ALLOCATED( BXHEIGHT ) ) DEALLOCATE( BXHEIGHT )
      IF ( ALLOCATED( CLDF     ) ) DEALLOCATE( CLDF     )
      IF ( ALLOCATED( CLDFRC   ) ) DEALLOCATE( CLDFRC   )
      IF ( ALLOCATED( CLDMAS   ) ) DEALLOCATE( CLDMAS   )
      IF ( ALLOCATED( CLDTOPS  ) ) DEALLOCATE( CLDTOPS  )
      IF ( ALLOCATED( CLMOSW   ) ) DEALLOCATE( CLMOSW   )
      IF ( ALLOCATED( CLROSW   ) ) DEALLOCATE( CLROSW   )
      IF ( ALLOCATED( DELP     ) ) DEALLOCATE( DELP     )
      IF ( ALLOCATED( DTRAIN   ) ) DEALLOCATE( DTRAIN   )
      IF ( ALLOCATED( GWETTOP  ) ) DEALLOCATE( GWETTOP  )
      IF ( ALLOCATED( HFLUX    ) ) DEALLOCATE( HFLUX    )
      IF ( ALLOCATED( HKBETA   ) ) DEALLOCATE( HKBETA   )
      IF ( ALLOCATED( HKETA    ) ) DEALLOCATE( HKETA    )
      IF ( ALLOCATED( LWI      ) ) DEALLOCATE( LWI      )
      IF ( ALLOCATED( MOISTQ   ) ) DEALLOCATE( MOISTQ   )
      IF ( ALLOCATED( OPTD     ) ) DEALLOCATE( OPTD     )
      IF ( ALLOCATED( OPTDEP   ) ) DEALLOCATE( OPTDEP   )
      IF ( ALLOCATED( PARDF    ) ) DEALLOCATE( PARDF    )
      IF ( ALLOCATED( PARDR    ) ) DEALLOCATE( PARDR    )
      IF ( ALLOCATED( PBL      ) ) DEALLOCATE( PBL      )
      IF ( ALLOCATED( PHIS     ) ) DEALLOCATE( PHIS     )
      IF ( ALLOCATED( PREACC   ) ) DEALLOCATE( PREACC   )
      IF ( ALLOCATED( PRECON   ) ) DEALLOCATE( PRECON   )
      IF ( ALLOCATED( PS1      ) ) DEALLOCATE( PS1      )
      IF ( ALLOCATED( PS2      ) ) DEALLOCATE( PS2      )
      IF ( ALLOCATED( PSC2     ) ) DEALLOCATE( PSC2     )
      IF ( ALLOCATED( RADLWG   ) ) DEALLOCATE( RADLWG   )
      IF ( ALLOCATED( RADSWG   ) ) DEALLOCATE( RADSWG   )
      IF ( ALLOCATED( RH       ) ) DEALLOCATE( RH       )
      IF ( ALLOCATED( SLP      ) ) DEALLOCATE( SLP      )
      IF ( ALLOCATED( SNOW     ) ) DEALLOCATE( SNOW     )
      IF ( ALLOCATED( SPHU1    ) ) DEALLOCATE( SPHU1    )
      IF ( ALLOCATED( SPHU2    ) ) DEALLOCATE( SPHU2    )
      IF ( ALLOCATED( SPHU     ) ) DEALLOCATE( SPHU     )
      IF ( ALLOCATED( SUNCOS   ) ) DEALLOCATE( SUNCOS   )
      IF ( ALLOCATED( SUNCOSB  ) ) DEALLOCATE( SUNCOSB  )
      IF ( ALLOCATED( T        ) ) DEALLOCATE( T        )
      IF ( ALLOCATED( TMPU1    ) ) DEALLOCATE( TMPU1    )
      IF ( ALLOCATED( TMPU2    ) ) DEALLOCATE( TMPU2    )
      IF ( ALLOCATED( TROPP    ) ) DEALLOCATE( TROPP    )
      IF ( ALLOCATED( TS       ) ) DEALLOCATE( TS       )
      IF ( ALLOCATED( TSKIN    ) ) DEALLOCATE( TSKIN    )
      IF ( ALLOCATED( U10M     ) ) DEALLOCATE( U10M     )
      IF ( ALLOCATED( USTAR    ) ) DEALLOCATE( USTAR    )
      IF ( ALLOCATED( UWND     ) ) DEALLOCATE( UWND     )
      IF ( ALLOCATED( UWND1    ) ) DEALLOCATE( UWND1    )
      IF ( ALLOCATED( UWND2    ) ) DEALLOCATE( UWND2    )
      IF ( ALLOCATED( V10M     ) ) DEALLOCATE( V10M     ) 
      IF ( ALLOCATED( VWND     ) ) DEALLOCATE( VWND     )
      IF ( ALLOCATED( VWND1    ) ) DEALLOCATE( VWND1    )
      IF ( ALLOCATED( VWND2    ) ) DEALLOCATE( VWND2    )
      IF ( ALLOCATED( WIND_10M ) ) DEALLOCATE( WIND_10M )
      IF ( ALLOCATED( Z0       ) ) DEALLOCATE( Z0       )
      IF ( ALLOCATED( ZMEU     ) ) DEALLOCATE( ZMEU     )
      IF ( ALLOCATED( ZMMD     ) ) DEALLOCATE( ZMMD     )
      IF ( ALLOCATED( ZMMU     ) ) DEALLOCATE( ZMMU     )

      ! Return to calling program
      END SUBROUTINE CLEANUP_DAO

!------------------------------------------------------------------------------

      END MODULE DAO_MOD
