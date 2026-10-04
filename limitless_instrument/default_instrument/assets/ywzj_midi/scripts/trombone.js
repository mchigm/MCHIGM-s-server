function noteToSlide(note) {
    var remainder = note % 12
    switch (remainder) {
        case 0: case 1: return 6
        case 2: case 3: return 5
        case 4: case 5: return 4
        case 6: case 7: return 3
        case 8: case 9: return 2
        case 10: return 1
        case 11: return 0
        default: return 0
    }
}

function getPlayPose(context) {
    var note = context.getNote()
    var slide = noteToSlide(note)

    var builder = createPoseBuilder()
    builder.setLeftArm(-1.7, 0.5, 0, null, 4.0, null)
    builder.setRightArmRotation(-1.7, slide * 0.02 - 0.5, 0)
    builder.setRightArmPosition(null, 4.0, -slide)
    return builder
}

function getHoldPose(context) {
    if (!context.isOffHand()) return null
    var builder = createPoseBuilder()
    builder.setLeftArm(-1.0, 0.5, 0, null, 4.0, null)
    builder.setRightArm(-1.0, -0.5, 0, null, 4.0, null)
    return builder
}
