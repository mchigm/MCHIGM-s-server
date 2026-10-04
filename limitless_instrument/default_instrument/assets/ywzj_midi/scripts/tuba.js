function getPlayPose(context) {
    var builder = createPoseBuilder()
    builder.setLeftArmRotation(-0.4, null, 0)
    builder.setRightArmRotation(-1.1, null, 0)
    return builder
}

function getHoldPose(context) {
    if (!context.isMainHand()) return null
    var builder = createPoseBuilder()
    builder.setLeftArmRotation(-0.3, null, 0)
    builder.setRightArmRotation(-1.0, null, 0)
    return builder
}
