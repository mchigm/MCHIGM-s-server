var KEY_NOTE_NAMES = ["a", "as", "b", "c", "cs", "d", "ds", "e", "f", "fs", "g", "gs"]

function noteToBoneName(note) {
    var octave = Math.floor((note + 3) / 12) - 1
    var noteIndex = (note + 3) % 12
    return KEY_NOTE_NAMES[noteIndex] + octave
}

function getPlayPose(context) {
    var notes = context.getNotes()
    if (!notes) {
        return null
    }

    var shifted = []
    for (var i = 0; i < notes.length; i++) {
        shifted[i] = notes[i] - 21
    }

    var sum = 0
    for (var i = 0; i < shifted.length; i++) {
        sum += shifted[i]
    }
    var average = shifted.length > 0 ? sum / shifted.length : 0

    var posLeftHand = null
    var posRightHand = null

    if (shifted.length < 5) {
        if (average < 44) {
            posLeftHand = average
        } else {
            posRightHand = average
        }
    } else {
        var leftSum = 0, leftCount = 0
        var rightSum = 0, rightCount = 0
        for (var i = 0; i < shifted.length; i++) {
            if (shifted[i] <= average) {
                leftSum += shifted[i]
                leftCount++
            } else {
                rightSum += shifted[i]
                rightCount++
            }
        }
        posLeftHand = leftCount > 0 ? leftSum / leftCount : 0
        posRightHand = rightCount > 0 ? rightSum / rightCount : 0
    }

    return calHandPose(posLeftHand, posRightHand)
}

function calHandPose(posLeftHand, posRightHand) {
    var builder = createPoseBuilder()
    builder.setLeftArmRotation(-1.1, null, null)
    builder.setRightArmRotation(-1.1, null, null)
    builder.setLeftArmPosition(null, 3.5, -2.2)
    builder.setRightArmPosition(null, 3.5, -2.2)
    if (posLeftHand !== null) {
        var r = (33 - posLeftHand) / 33
        builder.setLeftArmRotation(-1.1 + 0.4 * r, null, -1.3 * r)
        builder.setLeftArmPosition(null, null, -2.2 - 2 * r)
    }
    if (posRightHand !== null) {
        var r = (posRightHand - 55) / 33
        builder.setRightArmRotation(-1.1 + 0.4 * r, null, 1.3 * r)
        builder.setRightArmPosition(null, null, -2.2 - 2 * r)
    }
    return builder
}

function getHoldPose() {
    return createPoseBuilder()
}

function getModelPose(context) {
    var notes = context.getNotes()
    if (!notes || notes.length === 0) {
        return null
    }

    var builder = createPoseBuilder()
    for (var i = 0; i < notes.length; i++) {
        var boneName = noteToBoneName(notes[i])
        builder.setRotation(boneName, null, null, -5)
    }
    return builder
}
