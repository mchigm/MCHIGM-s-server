function getPlayPose(context) {
    var builder = createPoseBuilder()
    builder.setLeftArm(-2.0, 0.6, 0, null, 4.0, -3.0)
    builder.setRightArm(-0.6, 0.35, 0, null, 3.0, 1.5)
    return builder
}

function getHoldPose(context) {
    if (!context.isMainHand()) return null
    var builder = createPoseBuilder()
    builder.setLeftArm(-1.0, 0.6, 0, null, 3.0, -3.0)
    builder.setRightArm(-0.6, 0.2, 0.3, null, 4.0, 1.5)
    return builder
}
