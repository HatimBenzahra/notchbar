import SwiftUI

struct SpiderView: View {

    var threadLength: CGFloat = 30

    private let bodyRadius: CGFloat = 7
    private let headRadius: CGFloat = 5.5
    private let eyeRadius: CGFloat = 2.8
    private let pupilRadius: CGFloat = 1.4
    private let legLength: CGFloat = 10
    private let legStroke: CGFloat = 1.2
    private let threadStroke: CGFloat = 0.6

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let anchorX = size.width / 2
                let anchorY: CGFloat = 0

                let sway = sin(t * 0.8) * 6
                let bob = sin(t * 1.3) * 2

                let spiderX = anchorX + sway
                let spiderY = anchorY + threadLength + bob

                drawThread(context: context, from: CGPoint(x: anchorX, y: anchorY), to: CGPoint(x: spiderX, y: spiderY))

                let bodyCenter = CGPoint(x: spiderX, y: spiderY + bodyRadius)
                let headCenter = CGPoint(x: spiderX, y: spiderY - headRadius * 0.2)

                drawLegs(context: context, center: bodyCenter, phase: t * 2.2)
                drawBody(context: context, center: bodyCenter)
                drawHead(context: context, center: headCenter)
                drawEyes(context: context, headCenter: headCenter, time: t)
                drawMouth(context: context, headCenter: headCenter)
            }
        }
        .frame(width: 50, height: threadLength + bodyRadius * 2 + headRadius * 2 + legLength + 8)
        .allowsHitTesting(false)
    }

    private func drawThread(context: GraphicsContext, from: CGPoint, to: CGPoint) {
        var path = Path()
        path.move(to: from)
        let ctrl = CGPoint(x: (from.x + to.x) / 2 + (to.x - from.x) * 0.3, y: (from.y + to.y) / 2)
        path.addQuadCurve(to: to, control: ctrl)
        context.stroke(path, with: .color(.white.opacity(0.15)), lineWidth: threadStroke)
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

    private func drawEyes(context: GraphicsContext, headCenter: CGPoint, time: Double) {
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
                let pupilOffsetX = sin(time * 0.6) * 0.6
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

    private func drawMouth(context: GraphicsContext, headCenter: CGPoint) {
        let mouthY = headCenter.y + headRadius * 0.45
        var path = Path()
        path.move(to: CGPoint(x: headCenter.x - 1.8, y: mouthY))
        path.addQuadCurve(
            to: CGPoint(x: headCenter.x + 1.8, y: mouthY),
            control: CGPoint(x: headCenter.x, y: mouthY + 1.5)
        )
        context.stroke(path, with: .color(.white.opacity(0.35)), lineWidth: 0.6)
    }

    private func drawLegs(context: GraphicsContext, center: CGPoint, phase: Double) {
        let legConfigs: [(base: Double, sway: Double)] = [
            (-0.9, 0.12), (-0.5, 0.15), (-0.15, 0.10), (0.2, 0.13),
            (0.9, 0.12), (0.5, 0.15), (0.15, 0.10), (-0.2, 0.13)
        ]

        for (i, leg) in legConfigs.enumerated() {
            let side: CGFloat = i < 4 ? -1 : 1
            let wiggle = sin(phase + Double(i) * 0.8) * leg.sway

            let startY = center.y - bodyRadius * 0.3 + CGFloat(i % 4) * 3.0
            let start = CGPoint(x: center.x, y: startY)

            let midAngle = leg.base + wiggle
            let mid = CGPoint(
                x: start.x + side * legLength * 0.6 * cos(midAngle),
                y: start.y + legLength * 0.5 * sin(midAngle + 0.4)
            )
            let end = CGPoint(
                x: mid.x + side * legLength * 0.5,
                y: mid.y + legLength * 0.4
            )

            var path = Path()
            path.move(to: start)
            path.addQuadCurve(to: mid, control: CGPoint(
                x: (start.x + mid.x) / 2 + side * 2,
                y: (start.y + mid.y) / 2 - 1
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
            SpiderView(threadLength: 40)
        }
        .frame(width: 100, height: 120)
    }
}
#endif
