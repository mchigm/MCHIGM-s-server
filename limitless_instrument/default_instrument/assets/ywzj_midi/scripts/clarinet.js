function getPlayPose(context) {
    var builder = createPoseBuilder()
    builder.setLeftArmRotation(-1.2, 0.5, 0)
    builder.setRightArmRotation(-1.2, -0.5, 0)
    return builder
}

function getHoldPose() {
    return null
}
