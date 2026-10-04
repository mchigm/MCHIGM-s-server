function getPlayPose(context) {
    var builder = createPoseBuilder()
    builder.setLeftArm(-1.2, 0.7, 0, 5.0, 4.0, 0)
    builder.setRightArm(-0.6, -0.2, 0, -6.0, 4.0, null)
    return builder
}

function getHoldPose(context) {
    if (!context.isMainHand()) return null
    var builder = createPoseBuilder()
    builder.setLeftArm(-0.8, 0.7, 0, 6.0, 4.0, 0)
    builder.setRightArm(-0.9, -0.8, 0.3, -6.0, 4.0, null)
    return builder
}
