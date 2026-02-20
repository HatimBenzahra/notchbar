import SwiftUI

struct SpiderView: View {

    var crawlWidth: CGFloat = 120

    private let bodyRadius: CGFloat = 7
    private let headRadius: CGFloat = 5.5
    private let eyeRadius: CGFloat = 2.8
    private let pupilRadius: CGFloat = 1.4
    private let legLength: CGFloat = 10
    private let legStroke: CGFloat = 1.2

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let centerY = size.height / 2
                let margin: CGFloat = 20

                let crawlRange = size.width - margin * 2
                let phase = t * 0.3
                let normalized = (sin(phase) + 1) / 2
                let spiderX = margin + crawlRange * normalized

                let direction: CGFloat = cos(phase) > 0 ? 1 : -1
                let bob = sin(t * 3.0) * 0.6

                let bodyCenter = CGPoint(x: spiderX, y: centerY + bob)
                let headCenter = CGPoint(
                    x: spiderX + direction * (bodyRadius + headRadius * 0.5),
                    y: centerY - 1 + bob
                )

                let walkPhase = t * 6.0
                drawLegs(context: context, center: bodyCenter, phase: walkPhase, direction: direction)
                drawBody(context: context, center: bodyCenter)
                drawHead(context: context, center: headCenter)
                drawEyes(context: context, headCenter: headCenter, time: t, direction: direction)
                drawMouth(context: context, headCenter: headCenter, direction: direction)
            }
        }
        .frame(width: crawlWidth, height: bodyRadius * 2 + legLength * 2 + 6)
        .allowsHitTesting(false)
    }

    private func drawBody(context: GraphicsContext, center: CGPoint) {
        let bodyRect = CGRect(
            x: center.x - bodyRadius,
            y: center.y - bodyRadius * 1.15,
            width: bodyRadius * 2,
            height: bodyRadius * 2.3
        )
        let bodyPath = Path(ellipseIn: bodyRect)
        context.fill(bodyPath, with: .color(.white.opacity(0.12)))
        context.stroke(bodyPath, with: .color(.white.opacity(0.20)), lineWidth: 0.6)
    }

    private func drawHead(context: GraphicsContext, center: CGPoint) {
        let headRect = CGRect(
            x: center.x - headRadius,
            y: center.y - headRadius,
            width: headRadius * 2,
            height: headRadius * 2
        )
        let headPath = Path(ellipseIn: headRect)
        context.fill(headPath, with: .color(.white.opacity(0.15)))
        context.stroke(headPath, with: .color(.white.opacity(0.22)), lineWidth: 0.6)
    }

    private func drawEyes(context: GraphicsContext, headCenter: CGPoint, time: Double, direction: CGFloat) {
        let eyeSpacing: CGFloat = 3.2
        let eyeY = headCenter.y - 0.8

        let blinkCycle = time.truncatingRemainder(dividingBy: 4.0)
        let eyeScaleY: CGFloat = (blinkCycle > 3.7 && blinkCycle < 3.9) ? 0.15 : 1.0

        for side in [-1.0, 1.0] {
            let eyeX = headCenter.x + eyeSpacing * side

            let eyeRect = CGRect(
                x: eyeX - eyeRadius,
                y: eyeY - eyeRadius * eyeScaleY,
                width: eyeRadius * 2,
                height: eyeRadius * 2 * eyeScaleY
            )
            let eyePath = Path(ellipseIn: eyeRect)
            context.fill(eyePath, with: .color(.white.opacity(0.90)))

            if eyeScaleY > 0.5 {
                let pupilOffsetX = direction * 0.8
                let pupilRect = CGRect(
                    x: eyeX + pupilOffsetX - pupilRadius,
                    y: eyeY - pupilRadius * 0.8,
                    width: pupilRadius * 2,
                    height: pupilRadius * 2
                )
                let pupilPath = Path(ellipseIn: pupilRect)
                context.fill(pupilPath, with: .color(.black.opacity(0.85)))

                let shineRect = CGRect(
                    x: eyeX + pupilOffsetX + pupilRadius * 0.2,
                    y: eyeY - pupilRadius * 0.6,
                    width: pupilRadius * 0.7,
                    height: pupilRadius * 0.7
                )
                let shinePath = Path(ellipseIn: shineRect)
                context.fill(shinePath, with: .color(.white.opacity(0.80)))
            }
        }
    }

    private func drawMouth(context: GraphicsContext, headCenter: CGPoint, direction: CGFloat) {
        let mouthX = headCenter.x + direction * 1.5
        let mouthY = headCenter.y + headRadius * 0.45
        var path = Path()
        path.move(to: CGPoint(x: mouthX - 1.8, y: mouthY))
        path.addQuadCurve(
            to: CGPoint(x: mouthX + 1.8, y: mouthY),
            control: CGPoint(x: mouthX, y: mouthY + 1.5)
        )
        context.stroke(path, with: .color(.white.opacity(0.35)), lineWidth: 0.6)
    }

    private func drawLegs(context: GraphicsContext, center: CGPoint, phase: Double, direction: CGFloat) {
        for i in 0..<8 {
            let side: CGFloat = i < 4 ? -1 : 1
            let legIndex = i % 4

            let stepPhase = phase + Double(legIndex) * .pi / 2
            let stepLift = max(0, sin(stepPhase)) * 3.0
            let stepReach = cos(stepPhase) * 3.0

            let angles: [CGFloat] = [-0.6, -0.25, 0.15, 0.5]
            let baseAngle = angles[legIndex]

            let startY = center.y - bodyRadius * 0.2 + CGFloat(legIndex) * 2.8
            let start = CGPoint(x: center.x, y: startY)

            let mid = CGPoint(
                x: start.x + side * legLength * 0.6 + stepReach * side * 0.3,
                y: start.y + legLength * 0.3 * baseAngle - stepLift * 0.5
            )
            let end = CGPoint(
                x: mid.x + side * legLength * 0.5 + stepReach * side * 0.2,
                y: mid.y + legLength * 0.35 - stepLift * 0.3
            )

            var path = Path()
            path.move(to: start)
            path.addQuadCurve(to: mid, control: CGPoint(
                x: (start.x + mid.x) / 2 + side * 2,
                y: (start.y + mid.y) / 2 - 2
            ))
            path.addLine(to: end)

            context.stroke(path, with: .color(.white.opacity(0.18)), lineWidth: legStroke)
        }
    }
}

#if DEBUG
struct SpiderView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SpiderView(crawlWidth: 200)
        }
        .frame(width: 250, height: 60)
    }
}
#endif
