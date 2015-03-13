using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class HUSLTest : MonoBehaviour 
{
    [SerializeField] TextAsset Data;

    protected void AssertEqual(string a, string b)
    {
        if (a != b)
        {
            Debug.Log(a + " != " + b);
        }
    }

    protected void AssertTuplesClose(IList<double> a, IList<double> b)
    {
        bool mismatch = false;

        for (int i = 0; i < a.Count; ++i)
        {
            if (Math.Abs(a[i] - b[i]) >= 0.00000001)
            {
                mismatch = true;
            }
        }

        if (mismatch)
        {
            Debug.Log(string.Format("{0},{1},{2} vs {3},{4},{5}", a[0], a[1], a[2], b[0], b[1], b[2]));
        }
    }

    protected IList<double> Cast(object o)
    {
        var tuple = new List<double>();

        foreach (object value in (o as IList<object>))
        {
            double bv;
            
            if (value.GetType() == typeof(Int64))
            {
                bv = (double) ((Int64) value);
            }
            else
            {
                bv = (double) value;
            }

            tuple.Add(bv);
        }

        return tuple;
    }

    [ContextMenu("Test HUSL")]
    public void Test()
    {
        var data = MiniJSON.Json.Deserialize(Data.text) as Dictionary<string, object>;

        foreach (KeyValuePair<string, object> pair in data)
        {
            var expected = pair.Value as Dictionary<string, object>;

            // test forward functions
            var test_rgb = HUSL.HexToRGB(pair.Key);
            AssertTuplesClose(test_rgb, Cast(expected["rgb"]));
            var test_xyz = HUSL.RGBToXYZ(test_rgb);
            AssertTuplesClose(test_xyz, Cast(expected["xyz"]));
            var test_luv = HUSL.XYZToLUV(test_xyz);
            AssertTuplesClose(test_luv, Cast(expected["luv"]));
            var test_lch = HUSL.LUVToLCH(test_luv);
            AssertTuplesClose(test_lch, Cast(expected["lch"]));
            var test_husl = HUSL.LCHToHUSL(test_lch);
            AssertTuplesClose(test_husl, Cast(expected["husl"]));
            var test_huslp = HUSL.LCHToHUSLP(test_lch);
            AssertTuplesClose(test_huslp, Cast(expected["huslp"]));

            // test backward functions
            test_lch = HUSL.HUSLToLCH(Cast(expected["husl"]));
            AssertTuplesClose(test_lch, Cast(expected["lch"]));
            test_lch = HUSL.HUSLPToLCH(Cast(expected["huslp"]));
            AssertTuplesClose(test_lch, Cast(expected["lch"]));
            test_luv = HUSL.LCHToLUV(test_lch);
            AssertTuplesClose(test_luv, Cast(expected["luv"]));
            test_xyz = HUSL.LUVToXYZ(Cast(expected["luv"]));
            AssertTuplesClose(test_xyz, Cast(expected["xyz"]));
            test_rgb = HUSL.XYZToRGB(Cast(expected["xyz"]));
            AssertTuplesClose(test_rgb, Cast(expected["rgb"]));
            AssertEqual(HUSL.RGBToHex(test_rgb), pair.Key);

            // full test
            //Assert(HUSL.HUSLToHex(Cast(expected["husl"])) == pair.Key);
            //assert_tuples_close({husl.hex_to_husl(hex_color)}, colors.husl)
            //Assert(HUSL.HUSLPToHex() == pair.Key);
            //assert_tuples_close({husl.hex_to_huslp(hex_color)}, colors.huslp)
        }
    }
}
