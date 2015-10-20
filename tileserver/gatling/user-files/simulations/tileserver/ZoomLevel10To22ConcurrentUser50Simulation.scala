package tileserver

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._

class ZoomLevel10To22ConcurrentUser50Simulation extends Simulation {

	val httpProtocol = http
		.baseURL("http://ec2-52-30-184-45.eu-west-1.compute.amazonaws.com")
		.inferHtmlResources()

	val headers_0 = Map(
		"Accept" -> "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
		"Upgrade-Insecure-Requests" -> "1")

	val headers_1 = Map(
		"Accept" -> "application/json",
		"X-Requested-With" -> "XMLHttpRequest")

    val uri1 = "http://ec2-52-30-184-45.eu-west-1.compute.amazonaws.com"

	val scn = scenario("ZoomLevel10To22ConcurrentUser50Simulation")
		.exec(http("request_0")
			.get("/")
			.headers(headers_0)
			.resources(http("request_1")
			.get(uri1 + "/index.json")
			.headers(headers_1),
            http("request_2")
			.get(uri1 + "/images/transparent.png"),
            http("request_3")
			.get(uri1 + "/images/geosearch.png"),
            http("request_4")
			.get(uri1 + "/10/535/359.png"),
            http("request_5")
			.get(uri1 + "/10/536/358.png"),
            http("request_6")
			.get(uri1 + "/10/535/357.png"),
            http("request_7")
			.get(uri1 + "/10/536/359.png"),
            http("request_8")
			.get(uri1 + "/10/537/358.png"),
            http("request_9")
			.get(uri1 + "/10/535/358.png"),
            http("request_10")
			.get(uri1 + "/10/536/357.png"),
            http("request_11")
			.get(uri1 + "/10/534/359.png"),
            http("request_12")
			.get(uri1 + "/10/534/358.png"),
            http("request_13")
			.get(uri1 + "/10/535/360.png"),
            http("request_14")
			.get(uri1 + "/10/537/359.png"),
            http("request_15")
			.get(uri1 + "/10/536/360.png"),
            http("request_16")
			.get(uri1 + "/10/534/360.png"),
            http("request_17")
			.get(uri1 + "/10/534/357.png"),
            http("request_18")
			.get(uri1 + "/10/537/357.png"),
            http("request_19")
			.get(uri1 + "/10/537/360.png")))
		.exec(http("request_20")
			.get("/11/1072/716.png")
			.resources(http("request_21")
			.get(uri1 + "/11/1071/717.png"),
            http("request_22")
			.get(uri1 + "/11/1071/716.png"),
            http("request_23")
			.get(uri1 + "/11/1072/717.png"),
            http("request_24")
			.get(uri1 + "/11/1073/717.png"),
            http("request_25")
			.get(uri1 + "/11/1073/716.png"),
            http("request_26")
			.get(uri1 + "/11/1072/715.png"),
            http("request_27")
			.get(uri1 + "/11/1072/718.png"),
            http("request_28")
			.get(uri1 + "/11/1071/718.png"),
            http("request_29")
			.get(uri1 + "/11/1073/715.png"),
            http("request_30")
			.get(uri1 + "/11/1071/715.png"),
            http("request_31")
			.get(uri1 + "/11/1073/718.png")))
		.exec(http("request_32")
			.get("/12/2146/1433.png")
			.resources(http("request_33")
			.get(uri1 + "/12/2144/1433.png"),
            http("request_34")
			.get(uri1 + "/12/2145/1434.png"),
            http("request_35")
			.get(uri1 + "/12/2145/1433.png"),
            http("request_36")
			.get(uri1 + "/12/2144/1434.png"),
            http("request_37")
			.get(uri1 + "/12/2144/1432.png"),
            http("request_38")
			.get(uri1 + "/12/2145/1432.png"),
            http("request_39")
			.get(uri1 + "/12/2146/1434.png"),
            http("request_40")
			.get(uri1 + "/12/2143/1433.png"),
            http("request_41")
			.get(uri1 + "/12/2145/1435.png"),
            http("request_42")
			.get(uri1 + "/12/2143/1434.png"),
            http("request_43")
			.get(uri1 + "/12/2143/1435.png"),
            http("request_44")
			.get(uri1 + "/12/2144/1435.png"),
            http("request_45")
			.get(uri1 + "/12/2143/1432.png"),
            http("request_46")
			.get(uri1 + "/12/2146/1432.png"),
            http("request_47")
			.get(uri1 + "/12/2146/1435.png")))
		.exec(http("request_48")
			.get("/13/4289/2867.png")
			.resources(http("request_49")
			.get(uri1 + "/13/4289/2869.png"),
            http("request_50")
			.get(uri1 + "/13/4289/2868.png"),
            http("request_51")
			.get(uri1 + "/13/4290/2868.png"),
            http("request_52")
			.get(uri1 + "/13/4290/2869.png"),
            http("request_53")
			.get(uri1 + "/13/4291/2868.png"),
            http("request_54")
			.get(uri1 + "/13/4290/2867.png"),
            http("request_55")
			.get(uri1 + "/13/4288/2869.png"),
            http("request_56")
			.get(uri1 + "/13/4288/2868.png"),
            http("request_57")
			.get(uri1 + "/13/4289/2870.png"),
            http("request_58")
			.get(uri1 + "/13/4288/2870.png"),
            http("request_59")
			.get(uri1 + "/13/4290/2870.png"),
            http("request_60")
			.get(uri1 + "/13/4291/2869.png"),
            http("request_61")
			.get(uri1 + "/13/4288/2867.png"),
            http("request_62")
			.get(uri1 + "/13/4291/2870.png"),
            http("request_63")
			.get(uri1 + "/13/4291/2867.png")))
		.exec(http("request_64")
			.get("/14/8579/5737.png")
			.resources(http("request_65")
			.get(uri1 + "/14/8581/5737.png"),
            http("request_66")
			.get(uri1 + "/14/8580/5737.png"),
            http("request_67")
			.get(uri1 + "/14/8580/5736.png"),
            http("request_68")
			.get(uri1 + "/14/8579/5736.png"),
            http("request_69")
			.get(uri1 + "/14/8581/5736.png"),
            http("request_70")
			.get(uri1 + "/14/8580/5735.png"),
            http("request_71")
			.get(uri1 + "/14/8581/5735.png"),
            http("request_72")
			.get(uri1 + "/14/8580/5738.png"),
            http("request_73")
			.get(uri1 + "/14/8579/5735.png"),
            http("request_74")
			.get(uri1 + "/14/8579/5738.png"),
            http("request_75")
			.get(uri1 + "/14/8581/5738.png"),
            http("request_76")
			.get(uri1 + "/15/17162/11474.png"),
            http("request_77")
			.get(uri1 + "/15/17161/11474.png"),
            http("request_78")
			.get(uri1 + "/15/17161/11475.png"),
            http("request_79")
			.get(uri1 + "/15/17160/11474.png"),
            http("request_80")
			.get(uri1 + "/15/17160/11475.png"),
            http("request_81")
			.get(uri1 + "/15/17160/11473.png"),
            http("request_82")
			.get(uri1 + "/15/17159/11475.png"),
            http("request_83")
			.get(uri1 + "/15/17161/11473.png"),
            http("request_84")
			.get(uri1 + "/15/17159/11474.png"),
            http("request_85")
			.get(uri1 + "/15/17162/11475.png"),
            http("request_86")
			.get(uri1 + "/15/17160/11476.png"),
            http("request_87")
			.get(uri1 + "/15/17161/11476.png"),
            http("request_88")
			.get(uri1 + "/15/17159/11476.png"),
            http("request_89")
			.get(uri1 + "/15/17159/11473.png"),
            http("request_90")
			.get(uri1 + "/15/17162/11473.png"),
            http("request_91")
			.get(uri1 + "/15/17162/11476.png"),
            http("request_92")
			.get(uri1 + "/16/34321/22949.png"),
            http("request_93")
			.get(uri1 + "/16/34321/22950.png"),
            http("request_94")
			.get(uri1 + "/16/34322/22949.png"),
            http("request_95")
			.get(uri1 + "/16/34322/22950.png"),
            http("request_96")
			.get(uri1 + "/16/34321/22948.png"),
            http("request_97")
			.get(uri1 + "/16/34323/22949.png"),
            http("request_98")
			.get(uri1 + "/16/34320/22950.png"),
            http("request_99")
			.get(uri1 + "/16/34320/22949.png"),
            http("request_100")
			.get(uri1 + "/16/34322/22948.png"),
            http("request_101")
			.get(uri1 + "/16/34323/22950.png"),
            http("request_102")
			.get(uri1 + "/16/34322/22951.png"),
            http("request_103")
			.get(uri1 + "/16/34321/22951.png"),
            http("request_104")
			.get(uri1 + "/16/34320/22951.png"),
            http("request_105")
			.get(uri1 + "/16/34320/22948.png"),
            http("request_106")
			.get(uri1 + "/16/34323/22948.png"),
            http("request_107")
			.get(uri1 + "/16/34323/22951.png")))
		.exec(http("request_108")
			.get("/17/68643/45899.png")
			.resources(http("request_109")
			.get(uri1 + "/17/68643/45898.png"),
            http("request_110")
			.get(uri1 + "/17/68644/45899.png"),
            http("request_111")
			.get(uri1 + "/17/68644/45898.png"),
            http("request_112")
			.get(uri1 + "/17/68643/45897.png"),
            http("request_113")
			.get(uri1 + "/17/68645/45898.png"),
            http("request_114")
			.get(uri1 + "/17/68644/45897.png"),
            http("request_115")
			.get(uri1 + "/17/68642/45899.png"),
            http("request_116")
			.get(uri1 + "/17/68642/45898.png"),
            http("request_117")
			.get(uri1 + "/17/68645/45899.png"),
            http("request_118")
			.get(uri1 + "/17/68643/45900.png"),
            http("request_119")
			.get(uri1 + "/17/68644/45900.png"),
            http("request_120")
			.get(uri1 + "/17/68642/45900.png"),
            http("request_121")
			.get(uri1 + "/17/68642/45897.png"),
            http("request_122")
			.get(uri1 + "/17/68645/45897.png"),
            http("request_123")
			.get(uri1 + "/17/68645/45900.png")))
		.exec(http("request_124")
			.get("/18/137287/91797.png")
			.resources(http("request_125")
			.get(uri1 + "/18/137287/91798.png"),
            http("request_126")
			.get(uri1 + "/18/137288/91798.png"),
            http("request_127")
			.get(uri1 + "/18/137288/91797.png"),
            http("request_128")
			.get(uri1 + "/18/137287/91796.png"),
            http("request_129")
			.get(uri1 + "/18/137289/91797.png"),
            http("request_130")
			.get(uri1 + "/18/137288/91796.png"),
            http("request_131")
			.get(uri1 + "/18/137286/91798.png"),
            http("request_132")
			.get(uri1 + "/18/137286/91797.png"),
            http("request_133")
			.get(uri1 + "/18/137289/91798.png"),
            http("request_134")
			.get(uri1 + "/18/137288/91799.png"),
            http("request_135")
			.get(uri1 + "/18/137287/91799.png"),
            http("request_136")
			.get(uri1 + "/18/137286/91796.png"),
            http("request_137")
			.get(uri1 + "/18/137286/91799.png"),
            http("request_138")
			.get(uri1 + "/18/137289/91796.png"),
            http("request_139")
			.get(uri1 + "/18/137289/91799.png")))
		.exec(http("request_140")
			.get("/19/274576/183597.png")
			.resources(http("request_141")
			.get(uri1 + "/19/274576/183596.png"),
            http("request_142")
			.get(uri1 + "/19/274575/183597.png"),
            http("request_143")
			.get(uri1 + "/19/274575/183596.png"),
            http("request_144")
			.get(uri1 + "/19/274577/183596.png"),
            http("request_145")
			.get(uri1 + "/19/274577/183597.png"),
            http("request_146")
			.get(uri1 + "/19/274576/183595.png"),
            http("request_147")
			.get(uri1 + "/19/274576/183598.png"),
            http("request_148")
			.get(uri1 + "/19/274577/183595.png"),
            http("request_149")
			.get(uri1 + "/19/274575/183598.png"),
            http("request_150")
			.get(uri1 + "/19/274575/183595.png"),
            http("request_151")
			.get(uri1 + "/19/274577/183598.png")))
		.exec(http("request_152")
			.get("/20/549152/367194.png")
			.resources(http("request_153")
			.get(uri1 + "/20/549152/367193.png"),
            http("request_154")
			.get(uri1 + "/20/549152/367192.png"),
            http("request_155")
			.get(uri1 + "/20/549153/367193.png"),
            http("request_156")
			.get(uri1 + "/20/549154/367193.png"),
            http("request_157")
			.get(uri1 + "/20/549153/367194.png"),
            http("request_158")
			.get(uri1 + "/20/549151/367193.png"),
            http("request_159")
			.get(uri1 + "/20/549153/367192.png"),
            http("request_160")
			.get(uri1 + "/20/549151/367194.png"),
            http("request_161")
			.get(uri1 + "/20/549154/367194.png"),
            http("request_162")
			.get(uri1 + "/20/549153/367195.png"),
            http("request_163")
			.get(uri1 + "/20/549152/367195.png"),
            http("request_164")
			.get(uri1 + "/20/549151/367195.png"),
            http("request_165")
			.get(uri1 + "/20/549151/367192.png"),
            http("request_166")
			.get(uri1 + "/20/549154/367195.png"),
            http("request_167")
			.get(uri1 + "/20/549154/367192.png"),
            http("request_168")
			.get(uri1 + "/21/1098305/734386.png"),
            http("request_169")
			.get(uri1 + "/21/1098306/734386.png"),
            http("request_170")
			.get(uri1 + "/21/1098306/734387.png"),
            http("request_171")
			.get(uri1 + "/21/1098305/734387.png"),
            http("request_172")
			.get(uri1 + "/21/1098305/734385.png"),
            http("request_173")
			.get(uri1 + "/21/1098307/734386.png"),
            http("request_174")
			.get(uri1 + "/21/1098306/734385.png"),
            http("request_175")
			.get(uri1 + "/21/1098304/734387.png"),
            http("request_176")
			.get(uri1 + "/21/1098307/734387.png"),
            http("request_177")
			.get(uri1 + "/21/1098304/734386.png"),
            http("request_178")
			.get(uri1 + "/21/1098305/734388.png"),
            http("request_179")
			.get(uri1 + "/21/1098306/734388.png"),
            http("request_180")
			.get(uri1 + "/21/1098304/734385.png"),
            http("request_181")
			.get(uri1 + "/21/1098304/734388.png"),
            http("request_182")
			.get(uri1 + "/21/1098307/734385.png"),
            http("request_183")
			.get(uri1 + "/21/1098307/734388.png"),
            http("request_184")
			.get(uri1 + "/22/2196612/1468774.png"),
            http("request_185")
			.get(uri1 + "/22/2196611/1468774.png"),
            http("request_186")
			.get(uri1 + "/22/2196611/1468775.png"),
            http("request_187")
			.get(uri1 + "/22/2196612/1468775.png"),
            http("request_188")
			.get(uri1 + "/22/2196613/1468774.png"),
            http("request_189")
			.get(uri1 + "/22/2196611/1468773.png"),
            http("request_190")
			.get(uri1 + "/22/2196610/1468774.png"),
            http("request_191")
			.get(uri1 + "/22/2196612/1468773.png"),
            http("request_192")
			.get(uri1 + "/22/2196613/1468775.png"),
            http("request_193")
			.get(uri1 + "/22/2196610/1468775.png"),
            http("request_194")
			.get(uri1 + "/22/2196611/1468776.png"),
            http("request_195")
			.get(uri1 + "/22/2196612/1468776.png"),
            http("request_196")
			.get(uri1 + "/22/2196610/1468776.png"),
            http("request_197")
			.get(uri1 + "/22/2196610/1468773.png"),
            http("request_198")
			.get(uri1 + "/22/2196613/1468773.png"),
            http("request_199")
			.get(uri1 + "/22/2196613/1468776.png")))

	setUp(scn.inject(atOnceUsers(50))).protocols(httpProtocol)
}