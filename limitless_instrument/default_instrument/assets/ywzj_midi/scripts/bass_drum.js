function getStrikePose(context) {
    var frame = (context.getInt("strikeFrame", 0) + 1) % 20
    context.setInt("strikeFrame", frame)

    let offset
    if (frame < 5) {
        offset = frame * 0.06
    } else if (frame < 15) {
        offset = 0.3 - (frame - 5) * 0.06
    } else {
        offset = -0.3 + (frame - 15) * 0.06
    }

    var builder = createPoseBuilder()
    builder.setLeftArm(-0.9 + offset, 0.3, 0, null, null, null)
    builder.setRightArm(-0.9 - offset, -0.3, 0, null, null, null)
    return builder
}

function getPlayPose(context) {
    return getStrikePose(context)
}

function getHoldPose() {
    return createPoseBuilder()
}
