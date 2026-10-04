function getPlayPose(context) {
    var builder = createPoseBuilder()
    builder.setLeftArm(-1.8, 0.5, 0, null, 4.0, null)
    builder.setRightArm(-1.8, -0.5, 0, null, 4.0, null)
    return builder
}

function getHoldPose(context) {
    if (!context.isMainHand()) return null
    var builder = createPoseBuilder()
    builder.setLeftArm(-1.2, 0.5, 0, null, 4.0, null)
    builder.setRightArm(-1.2, -0.5, 0, null, 4.0, null)
    return builder
}
