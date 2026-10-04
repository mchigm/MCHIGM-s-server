function getStrikePose(context) {
    var frame = context.getInt("strikeFrame", 0)
    var dir = context.getInt("strikeDir", 1)
    var maxFrame = 4

    let nextFrame = frame + dir
    let nextDir = dir
    if (nextFrame > maxFrame) {
        nextFrame = maxFrame - 1
        nextDir = -1
    } else if (nextFrame < 0) {
        nextFrame = 0
        nextDir = 1
    }
    context.setInt("strikeFrame", nextFrame)
    context.setInt("strikeDir", nextDir)

    var offset = (frame + 1) * 0.06

    var builder = createPoseBuilder()
    builder.setLeftArm(-1.0, offset, 0.02, null, null, null)
    builder.setRightArm(-1.0, -offset, -0.02, null, null, null)
    return builder
}

function getPlayPose(context) {
    return getStrikePose(context)
}

function getHoldPose(context) {
    if (!context.isMainHand()) return null
    var builder = createPoseBuilder()
    builder.setLeftArmRotation(-1.0, 0, 0.02)
    builder.setRightArmRotation(-1.0, 0, -0.02)
    return builder
}
