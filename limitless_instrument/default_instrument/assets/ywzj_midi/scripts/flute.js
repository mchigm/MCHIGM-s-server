function getPlayPose(context) {
    var builder = createPoseBuilder()
    builder.setLeftArm(-2.0, 1.2, 0, 1.5, 4.5, -3.0)
    builder.setRightArm(-2.4, 0.8, 0, null, 5.5, null)
    return builder
}

function getHoldPose(context) {
    if (!context.isMainHand()) return null
    var builder = createPoseBuilder()
    builder.setRightArmRotation(-0.6, null, null)
    return builder
}
