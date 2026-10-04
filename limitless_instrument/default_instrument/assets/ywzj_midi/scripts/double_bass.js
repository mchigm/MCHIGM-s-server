var PULL_PUSH_STEPS = 21

function getPlayPose(context) {
    var variantId = context.getInt("variantId", 0)

    if (variantId === 0) {
        var bowStep = context.getInt("step", 0)
        var isPull = context.getBool("isPull", true)

        var newStep, newIsPull
        if (isPull) {
            newStep = bowStep + 1
            newIsPull = true
            if (newStep >= PULL_PUSH_STEPS - 1) {
                newStep = PULL_PUSH_STEPS - 1
                newIsPull = false
            }
        } else {
            newStep = bowStep - 1
            newIsPull = false
            if (newStep <= 0) {
                newStep = 0
                newIsPull = true
            }
        }
        context.setInt("step", newStep)
        context.setBool("isPull", newIsPull)

        var bowRot = -0.25 + (newStep / (PULL_PUSH_STEPS - 1)) * 0.5
        var bias = (bowRot + 0.25) / 0.5

        var bowBuilder = createPoseBuilder()
        bowBuilder.setRightArm(
            -1.1 - bias * 0.05, bowRot, 0,
            null, 5.0, -3.8 + bias * 4.3
        )
        return bowBuilder
    } else {
        var pizzStepVal = context.getInt("pizzStep", 0)
        context.setInt("pizzStep", Math.min(pizzStepVal + 1, 6))

        var pizzRot = pizzStepVal * 0.04
        var pizzBuilder = createPoseBuilder()
        pizzBuilder.setLeftArmPosition(null, null, 2.3)
        pizzBuilder.setRightArm(
            -1.5 - pizzRot, -0.8, 0,
            null, 5.0, -3.5
        )
        return pizzBuilder
    }
}

function getHoldPose(context) {
    if (!context.isOffHand()) return null
    var holdBuilder = createPoseBuilder()
    holdBuilder.setLeftArm(-2.0, 0, 0.1, 3.2, null, 1.0)
    return holdBuilder
}
