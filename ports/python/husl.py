import operator
import math

class HuslConverter():

    m = [
            [3.2406, -1.5372, -0.4986],
            [-0.9689, 1.8758, 0.0415],
            [0.0557, -0.2040, 1.0570]
        ]

    m_inv = [
                [0.4124, 0.3576, 0.1805],
                [0.2126, 0.7152, 0.0722],
                [0.0193, 0.1192, 0.9505]
            ]
    refX = 0.95047
    refY = 1.00000
    refZ = 1.08883
    refU = 0.19784
    refV = 0.46834
    lab_e = 0.008856
    lab_k = 903.3


    #Pass in HUSL values and get back RGB values, H ranges from 0 to 360, S and L from 0 to 100.
    #RGB values will range from 0 to 1.
    def HUSLtoRGB(self, h, s, l):
        return self.XYZ_RGB(self.LUV_XYZ(self.LCH_LUV(self.HUSL_LCH([h, s, l]))))

    #Pass in RGB values ranging from 0 to 1 and get back HUSL values.
    #H ranges from 0 to 360, S and L from 0 to 100.
    def RGBtoHUSL(self, r, g, b):
        return self.LCH_HUSL(self.LUV_LCH(self.XYZ_LUV(self.RGB_XYZ([r, g, b]))))

    def maxChroma(self, L, H):
        _ref = [0.0, 1.0]

        hrad = ((H / 360.0) * 2 * math.pi)
        sinH = (math.sin(hrad))
        cosH = (math.cos(hrad))
        sub1 = (math.pow(L + 16, 3) / 1560896.0)
        sub2 = sub1 if sub1 > 0.008856 else (L / 903.3)
        result = float("inf")
        for row in self.m:
            m1 = row[0]
            m2 = row[1]
            m3 = row[2]
            top = ((0.99915 * m1 + 1.05122 * m2 + 1.14460 * m3) * sub2)
            rbottom = (0.86330 * m3 - 0.17266 * m2)
            lbottom = (0.12949 * m3 - 0.38848 * m1)
            bottom = (rbottom * sinH + lbottom * cosH) * sub2

            for t in _ref:
                C = (L * (top - 1.05122 * t) / (bottom + 0.17266 * sinH * t))
                if C > 0 and C < result:
                    result = C
        return result

    def dotProduct(self, a, b):
        return sum(map(operator.mul, a, b))


    def round(self, num, places):
        n = (math.pow(10.0, places))
        return (math.floor(num * n) / n)

    def f(self, t):
        if t > self.lab_e:
            return (math.pow(t, 1.0 / 3.0))
        else:
            return (7.787 * t + 16 / 116.0)

    def f_inv(self, t):
        if math.pow(t, 3) > self.lab_e:
            return (math.pow(t, 3))
        else:
            return (116 * t - 16) / self.lab_k

    def fromLinear(self, c):
        if c <= 0.0031308:
            return 12.92 * c
        else:
            return (1.055 * math.pow(c, 1 / 2.4) - 0.055)

    def toLinear(self, c):
        a = 0.055

        if c > 0.04045:
            return (math.pow((c + a) / (1 + a), 2.4))
        else:
            return (c / 12.92)

    def rgbPrepare(self, triple):
        for i in range(0, 3):
            triple[i] = round(triple[i], 3)

            if triple[i] < 0 or triple[i] > 1:
                if triple[i] < 0:
                    triple[i] = 0
                else:
                    triple[i] = 1

            triple[i] = round(triple[i]*255, 0)

        return triple

    def XYZ_RGB(self, triple):
        return [self.fromLinear(self.dotProduct(self.m[0], triple)),
                self.fromLinear(self.dotProduct(self.m[1], triple)),
                self.fromLinear(self.dotProduct(self.m[2], triple))]

    def RGB_XYZ(self, triple):
        R = triple[0]
        G = triple[1]
        B = triple[2]

        rgbl = [self.toLinear(R), self.toLinear(G), self.toLinear(B)]

        X = self.dotProduct(self.m_inv[0], rgbl, 3)
        Y = self.dotProduct(self.m_inv[1], rgbl, 3)
        Z = self.dotProduct(self.m_inv[2], rgbl, 3)

        return [X, Y, Z]

    def XYZ_LUV(self, triple):
        X = triple[0]
        Y = triple[1]
        Z = triple[2]

        varU = (4 * X) / (X + (15.0 * Y) + (3 * Z))
        varV = (9 * Y) / (X + (15.0 * Y) + (3 * Z))
        L = 116 * float(Y / self.refY) - 16
        U = 13 * L * (varU - self.refU)
        V = 13 * L * (varV - self.refV)

        return [L, U, V]

    def LUV_XYZ(self, triple):
        L = triple[0]
        U = triple[1]
        V = triple[2]

        if L == 0:
            triple[2] = triple[1] = triple[0] = 0.0
            return triple

        varY = self.f_inv((L + 16) / 116.0)
        varU = U / (13.0 * L) + self.refU
        varV = V / (13.0 * L) + self.refV
        Y = varY * self.refY
        X = 0 - (9 * Y * varU) / ((varU - 4.0) * varV - varU * varV)
        Z = (9 * Y - (15 * varV * Y) - (varV * X)) / (3.0 * varV)

        return [X, Y, Z]

    def LUV_LCH(self, triple):
        L = triple[0]
        U = triple[1]
        V = triple[2]

        C = (math.pow(math.pow(U, 2) + math.pow(V, 2), (1 / 2.0)))
        Hrad = (math.atan2(V, U))
        H = (Hrad * 360.0 / 2.0 / math.pi)
        if H < 0:
            H = 360 + H

        return [L, C, H]

    def LCH_LUV(self, triple):
        L = triple[0]
        C = triple[1]
        H = triple[2]

        Hrad = (H / 360.0 * 2.0 * math.pi)
        U = (math.cos(Hrad) * C)
        V = (math.sin(Hrad) * C)

        return [L, U, V]

    def HUSL_LCH(self, triple):
        H = triple[0]
        S = triple[1]
        L = triple[2]

        max = self.maxChroma(L, H)
        C = max / 100.0 * S

        return [L, C, H]

    def LCH_HUSL(self, triple):
        L = triple[0]
        C = triple[1]
        H = triple[2]

        max = self.maxChroma(L, H)
        S = C / max * 100

        return [H, S, L]
