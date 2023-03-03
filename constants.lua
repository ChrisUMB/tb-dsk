-- [ Decap Scripting Kit ] --

--[[
    The constants file is meant to provide useful utility for getting values with
    seemingly "magic number" values, like joint states/names, players, etcetera.

    IMPORTANT: Everything throughout DSK is meant to be one-indexed, as is the
    language you are writing this in. It's the way it should be, lua is a one-indexed
    language thus everything you do regarding array access, looping, et cetera should be
    as well. To try and make this as effortless as possible, the conversion between
    zero-indexing and one-indexing is handled for you internally throughout this class
    and elsewhere, like fighter.lua, so long as you use the functions provided. This helps prevent getting
    confused/looping incorrectly due to the messy fact that Toribash casually mixes
    zero-indexing and one indexing all over the place in scripting.

    PARTS.NAME is a table where the keys are the names of the parts.
    PARTS.ID is a table where the keys are the numeric ID of the parts.

    JOINTS follows the same style as the PART table.


]]

TORI_ID = 1
UKE_ID = 2

PART = {
    NAME = {
        HEAD        =  1,
        BREAST      =  2,
        CHEST       =  3,
        STOMACH     =  4,
        GROIN       =  5,
        R_PECS      =  6,
        R_BICEPS    =  7,
        R_TRICEPS   =  8,
        L_PECS      =  9,
        L_BICEPS    = 10,
        L_TRICEPS   = 11,
        R_HAND      = 12,
        L_HAND      = 13,
        R_BUTT      = 14,
        L_BUTT      = 15,
        R_THIGH     = 16,
        L_THIGH     = 17,
        L_LEG       = 18,
        R_LEG       = 19,
        R_FOOT      = 20,
        L_FOOT      = 21
    },

    ID = {
        "HEAD",
        "BREAST",
        "CHEST",
        "STOMACH",
        "GROIN",
        "R_PECS",
        "R_BICEPS",
        "R_TRICEPS",
        "L_PECS",
        "L_BICEPS",
        "L_TRICEPS",
        "R_HAND",
        "L_HAND",
        "R_BUTT",
        "L_BUTT",
        "R_THIGH",
        "L_THIGH",
        "L_LEG",
        "R_LEG",
        "R_FOOT",
        "L_FOOT"
    }
}

JOINT = {
    NAME = {
        NECK        =  1,
        CHEST       =  2,
        LUMBAR      =  3,
        ABS         =  4,
        R_PECS      =  5,
        R_SHOULDER  =  6,
        R_ELBOW     =  7,
        L_PECS      =  8,
        L_SHOULDER  =  9,
        L_ELBOW     = 10,
        R_WRIST     = 11,
        L_WRIST     = 12,
        R_GLUTE     = 13,
        L_GLUTE     = 14,
        R_HIP       = 15,
        L_HIP       = 16,
        R_KNEE      = 17,
        L_KNEE      = 18,
        R_ANKLE     = 19,
        L_ANKLE     = 20
    },
    ID = {
        "NECK",
        "CHEST",
        "LUMBAR",
        "ABS",
        "R_PECS",
        "R_SHOULDER",
        "R_ELBOW",
        "L_PECS",
        "L_SHOULDER",
        "L_ELBOW",
        "R_WRIST",
        "L_WRIST",
        "R_GLUTE",
        "L_GLUTE",
        "R_HIP",
        "L_HIP",
        "R_KNEE",
        "L_KNEE",
        "R_ANKLE",
        "L_ANKLE"
    }
}

MAX_ENV_OBJECTS = 128
MAX_DYNAMIC_ENV_OBJECTS = 16