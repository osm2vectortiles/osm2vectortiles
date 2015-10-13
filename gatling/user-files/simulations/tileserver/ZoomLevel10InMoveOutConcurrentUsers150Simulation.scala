package tileserver

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._

class ZoomLevel10InMoveOutConcurrentUsers150Simulation extends Simulation {

	val httpProtocol = http
		.baseURL("http://ec2-52-30-184-45.eu-west-1.compute.amazonaws.com")
		.inferHtmlResources()

	val headers_0 = Map(
		"Accept" -> "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
		"Upgrade-Insecure-Requests" -> "1")

	val headers_1 = Map("Accept" -> "text/css,*/*;q=0.1")

	val headers_3 = Map("Accept" -> "*/*")

	val headers_9 = Map(
		"Accept" -> "application/json",
		"X-Requested-With" -> "XMLHttpRequest")

    val uri1 = "http://ec2-52-30-184-45.eu-west-1.compute.amazonaws.com"

	val scn = scenario("ZoomLevel10InMoveOutConcurrentUsers150Simulation")
		.exec(http("request_0")
			.get("/")
			.headers(headers_0)
			.resources(http("request_1")
			.get(uri1 + "/leaflet/dist/leaflet.css"),
            http("request_2")
			.get(uri1 + "/css/l.geosearch.css"),
            http("request_3")
			.get(uri1 + "/js/l.control.geosearch.js"),
            http("request_4")
			.get(uri1 + "/leaflet/dist/leaflet.js"),
            http("request_5")
			.get(uri1 + "/leaflet-hash/leaflet-hash.js"),
            http("request_6")
			.get(uri1 + "/js/l.geosearch.provider.nominatim.js"),
            http("request_7")
			.get(uri1 + "/zepto/zepto.min.js"),
            http("request_8")
			.get(uri1 + "/images/transparent.png"),
            http("request_9")
			.get(uri1 + "/index.json"),
            http("request_10")
			.get(uri1 + "/images/geosearch.png")))
		.exec(http("request_11")
			.get("/11/1070/716.png")
			.resources(http("request_12")
			.get(uri1 + "/11/1070/717.png"),
            http("request_13")
			.get(uri1 + "/11/1070/718.png"),
            http("request_14")
			.get(uri1 + "/11/1070/715.png"),
            http("request_15")
			.get(uri1 + "/12/2143/1431.png"),
            http("request_16")
			.get(uri1 + "/12/2144/1431.png"),
            http("request_17")
			.get(uri1 + "/12/2142/1431.png"),
            http("request_18")
			.get(uri1 + "/12/2145/1431.png"),
            http("request_19")
			.get(uri1 + "/12/2142/1434.png"),
            http("request_20")
			.get(uri1 + "/12/2142/1433.png"),
            http("request_21")
			.get(uri1 + "/12/2142/1432.png"),
            http("request_22")
			.get(uri1 + "/13/4287/2865.png"),
            http("request_23")
			.get(uri1 + "/13/4287/2864.png"),
            http("request_24")
			.get(uri1 + "/13/4288/2864.png"),
            http("request_25")
			.get(uri1 + "/13/4287/2866.png"),
            http("request_26")
			.get(uri1 + "/13/4286/2865.png"),
            http("request_27")
			.get(uri1 + "/13/4288/2865.png"),
            http("request_28")
			.get(uri1 + "/13/4288/2866.png"),
            http("request_29")
			.get(uri1 + "/13/4286/2864.png"),
            http("request_30")
			.get(uri1 + "/13/4289/2864.png"),
            http("request_31")
			.get(uri1 + "/13/4289/2865.png"),
            http("request_32")
			.get(uri1 + "/13/4288/2863.png"),
            http("request_33")
			.get(uri1 + "/13/4287/2863.png"),
            http("request_34")
			.get(uri1 + "/13/4289/2866.png"),
            http("request_35")
			.get(uri1 + "/13/4286/2863.png"),
            http("request_36")
			.get(uri1 + "/13/4286/2866.png"),
            http("request_37")
			.get(uri1 + "/13/4289/2863.png"),
            http("request_38")
			.get(uri1 + "/14/8575/5730.png"),
            http("request_39")
			.get(uri1 + "/14/8575/5731.png"),
            http("request_40")
			.get(uri1 + "/14/8574/5731.png"),
            http("request_41")
			.get(uri1 + "/14/8574/5730.png"),
            http("request_42")
			.get(uri1 + "/14/8576/5731.png"),
            http("request_43")
			.get(uri1 + "/14/8575/5729.png"),
            http("request_44")
			.get(uri1 + "/14/8576/5730.png"),
            http("request_45")
			.get(uri1 + "/14/8575/5732.png"),
            http("request_46")
			.get(uri1 + "/14/8576/5729.png"),
            http("request_47")
			.get(uri1 + "/14/8574/5729.png"),
            http("request_48")
			.get(uri1 + "/14/8574/5732.png"),
            http("request_49")
			.get(uri1 + "/14/8576/5732.png")))
		.exec(http("request_50")
			.get("/15/17150/11460.png")
			.resources(http("request_51")
			.get(uri1 + "/15/17149/11461.png"),
            http("request_52")
			.get(uri1 + "/15/17150/11461.png"),
            http("request_53")
			.get(uri1 + "/15/17151/11460.png"),
            http("request_54")
			.get(uri1 + "/15/17149/11460.png"),
            http("request_55")
			.get(uri1 + "/15/17151/11461.png"),
            http("request_56")
			.get(uri1 + "/15/17150/11459.png"),
            http("request_57")
			.get(uri1 + "/15/17150/11462.png"),
            http("request_58")
			.get(uri1 + "/15/17149/11462.png"),
            http("request_59")
			.get(uri1 + "/15/17151/11459.png"),
            http("request_60")
			.get(uri1 + "/15/17149/11459.png"),
            http("request_61")
			.get(uri1 + "/15/17151/11462.png")))
		.exec(http("request_62")
			.get("/16/34300/22920.png")
			.resources(http("request_63")
			.get(uri1 + "/16/34301/22920.png"),
            http("request_64")
			.get(uri1 + "/16/34302/22920.png"),
            http("request_65")
			.get(uri1 + "/16/34301/22921.png"),
            http("request_66")
			.get(uri1 + "/16/34300/22921.png"),
            http("request_67")
			.get(uri1 + "/16/34300/22919.png"),
            http("request_68")
			.get(uri1 + "/16/34301/22919.png"),
            http("request_69")
			.get(uri1 + "/16/34299/22921.png"),
            http("request_70")
			.get(uri1 + "/16/34299/22920.png"),
            http("request_71")
			.get(uri1 + "/16/34302/22921.png"),
            http("request_72")
			.get(uri1 + "/16/34300/22922.png"),
            http("request_73")
			.get(uri1 + "/16/34301/22922.png"),
            http("request_74")
			.get(uri1 + "/16/34299/22919.png"),
            http("request_75")
			.get(uri1 + "/16/34299/22922.png"),
            http("request_76")
			.get(uri1 + "/16/34302/22919.png"),
            http("request_77")
			.get(uri1 + "/16/34302/22922.png"),
            http("request_78")
			.get(uri1 + "/17/68601/45841.png"),
            http("request_79")
			.get(uri1 + "/17/68600/45842.png"),
            http("request_80")
			.get(uri1 + "/17/68600/45841.png"),
            http("request_81")
			.get(uri1 + "/17/68601/45842.png"),
            http("request_82")
			.get(uri1 + "/17/68602/45841.png"),
            http("request_83")
			.get(uri1 + "/17/68600/45840.png"),
            http("request_84")
			.get(uri1 + "/17/68601/45840.png"),
            http("request_85")
			.get(uri1 + "/17/68599/45841.png"),
            http("request_86")
			.get(uri1 + "/17/68599/45842.png"),
            http("request_87")
			.get(uri1 + "/17/68602/45842.png"),
            http("request_88")
			.get(uri1 + "/17/68600/45843.png"),
            http("request_89")
			.get(uri1 + "/17/68601/45843.png"),
            http("request_90")
			.get(uri1 + "/17/68599/45843.png"),
            http("request_91")
			.get(uri1 + "/17/68602/45840.png"),
            http("request_92")
			.get(uri1 + "/17/68602/45843.png"),
            http("request_93")
			.get(uri1 + "/17/68599/45840.png"),
            http("request_94")
			.get(uri1 + "/18/137201/91683.png"),
            http("request_95")
			.get(uri1 + "/18/137201/91682.png"),
            http("request_96")
			.get(uri1 + "/18/137202/91683.png"),
            http("request_97")
			.get(uri1 + "/18/137202/91682.png"),
            http("request_98")
			.get(uri1 + "/18/137202/91684.png"),
            http("request_99")
			.get(uri1 + "/18/137201/91684.png"),
            http("request_100")
			.get(uri1 + "/18/137200/91682.png"),
            http("request_101")
			.get(uri1 + "/18/137203/91682.png"),
            http("request_102")
			.get(uri1 + "/18/137200/91683.png"),
            http("request_103")
			.get(uri1 + "/18/137203/91683.png"),
            http("request_104")
			.get(uri1 + "/18/137203/91684.png"),
            http("request_105")
			.get(uri1 + "/18/137200/91684.png"),
            http("request_106")
			.get(uri1 + "/18/137202/91681.png"),
            http("request_107")
			.get(uri1 + "/18/137201/91685.png"),
            http("request_108")
			.get(uri1 + "/18/137202/91685.png"),
            http("request_109")
			.get(uri1 + "/18/137201/91681.png"),
            http("request_110")
			.get(uri1 + "/18/137200/91681.png"),
            http("request_111")
			.get(uri1 + "/18/137200/91685.png"),
            http("request_112")
			.get(uri1 + "/18/137203/91681.png"),
            http("request_113")
			.get(uri1 + "/18/137203/91685.png"),
            http("request_114")
			.get(uri1 + "/19/274404/183367.png"),
            http("request_115")
			.get(uri1 + "/19/274404/183366.png"),
            http("request_116")
			.get(uri1 + "/19/274403/183367.png"),
            http("request_117")
			.get(uri1 + "/19/274403/183366.png"),
            http("request_118")
			.get(uri1 + "/19/274404/183365.png"),
            http("request_119")
			.get(uri1 + "/19/274403/183365.png"),
            http("request_120")
			.get(uri1 + "/19/274405/183366.png"),
            http("request_121")
			.get(uri1 + "/19/274402/183366.png"),
            http("request_122")
			.get(uri1 + "/19/274402/183365.png"),
            http("request_123")
			.get(uri1 + "/19/274405/183365.png"),
            http("request_124")
			.get(uri1 + "/19/274402/183367.png"),
            http("request_125")
			.get(uri1 + "/19/274405/183367.png"),
            http("request_126")
			.get(uri1 + "/19/274403/183364.png"),
            http("request_127")
			.get(uri1 + "/19/274404/183368.png"),
            http("request_128")
			.get(uri1 + "/19/274404/183364.png"),
            http("request_129")
			.get(uri1 + "/19/274403/183368.png"),
            http("request_130")
			.get(uri1 + "/19/274402/183368.png"),
            http("request_131")
			.get(uri1 + "/19/274402/183364.png"),
            http("request_132")
			.get(uri1 + "/19/274405/183364.png"),
            http("request_133")
			.get(uri1 + "/19/274405/183368.png"),
            http("request_134")
			.get(uri1 + "/20/548807/366732.png"),
            http("request_135")
			.get(uri1 + "/20/548808/366733.png"),
            http("request_136")
			.get(uri1 + "/20/548808/366732.png"),
            http("request_137")
			.get(uri1 + "/20/548807/366731.png"),
            http("request_138")
			.get(uri1 + "/20/548808/366731.png"),
            http("request_139")
			.get(uri1 + "/20/548807/366733.png"),
            http("request_140")
			.get(uri1 + "/20/548806/366732.png"),
            http("request_141")
			.get(uri1 + "/20/548806/366731.png"),
            http("request_142")
			.get(uri1 + "/20/548809/366732.png"),
            http("request_143")
			.get(uri1 + "/20/548809/366731.png"),
            http("request_144")
			.get(uri1 + "/20/548806/366733.png"),
            http("request_145")
			.get(uri1 + "/20/548809/366733.png"),
            http("request_146")
			.get(uri1 + "/20/548808/366730.png"),
            http("request_147")
			.get(uri1 + "/20/548807/366730.png"),
            http("request_148")
			.get(uri1 + "/20/548808/366734.png"),
            http("request_149")
			.get(uri1 + "/20/548807/366734.png"),
            http("request_150")
			.get(uri1 + "/20/548806/366734.png"),
            http("request_151")
			.get(uri1 + "/20/548809/366730.png"),
            http("request_152")
			.get(uri1 + "/20/548806/366730.png"),
            http("request_153")
			.get(uri1 + "/20/548809/366734.png"),
            http("request_154")
			.get(uri1 + "/21/1097615/733463.png"),
            http("request_155")
			.get(uri1 + "/21/1097616/733463.png"),
            http("request_156")
			.get(uri1 + "/21/1097615/733464.png"),
            http("request_157")
			.get(uri1 + "/21/1097616/733464.png"),
            http("request_158")
			.get(uri1 + "/21/1097615/733465.png"),
            http("request_159")
			.get(uri1 + "/21/1097616/733465.png"),
            http("request_160")
			.get(uri1 + "/21/1097614/733464.png"),
            http("request_161")
			.get(uri1 + "/21/1097617/733464.png"),
            http("request_162")
			.get(uri1 + "/21/1097614/733463.png"),
            http("request_163")
			.get(uri1 + "/21/1097617/733463.png"),
            http("request_164")
			.get(uri1 + "/21/1097614/733465.png"),
            http("request_165")
			.get(uri1 + "/21/1097617/733465.png"),
            http("request_166")
			.get(uri1 + "/21/1097616/733462.png"),
            http("request_167")
			.get(uri1 + "/21/1097616/733466.png"),
            http("request_168")
			.get(uri1 + "/21/1097615/733462.png"),
            http("request_169")
			.get(uri1 + "/21/1097615/733466.png"),
            http("request_170")
			.get(uri1 + "/21/1097614/733462.png"),
            http("request_171")
			.get(uri1 + "/21/1097614/733466.png"),
            http("request_172")
			.get(uri1 + "/21/1097617/733462.png"),
            http("request_173")
			.get(uri1 + "/21/1097617/733466.png"),
            http("request_174")
			.get(uri1 + "/22/2195231/1466928.png"),
            http("request_175")
			.get(uri1 + "/22/2195232/1466928.png"),
            http("request_176")
			.get(uri1 + "/22/2195231/1466927.png"),
            http("request_177")
			.get(uri1 + "/22/2195232/1466929.png"),
            http("request_178")
			.get(uri1 + "/22/2195231/1466929.png"),
            http("request_179")
			.get(uri1 + "/22/2195232/1466927.png"),
            http("request_180")
			.get(uri1 + "/22/2195230/1466928.png"),
            http("request_181")
			.get(uri1 + "/22/2195233/1466928.png"),
            http("request_182")
			.get(uri1 + "/22/2195233/1466927.png"),
            http("request_183")
			.get(uri1 + "/22/2195233/1466929.png"),
            http("request_184")
			.get(uri1 + "/22/2195230/1466927.png"),
            http("request_185")
			.get(uri1 + "/22/2195230/1466929.png"),
            http("request_186")
			.get(uri1 + "/22/2195232/1466926.png"),
            http("request_187")
			.get(uri1 + "/22/2195232/1466930.png"),
            http("request_188")
			.get(uri1 + "/22/2195231/1466930.png"),
            http("request_189")
			.get(uri1 + "/22/2195231/1466926.png"),
            http("request_190")
			.get(uri1 + "/22/2195230/1466930.png"),
            http("request_191")
			.get(uri1 + "/22/2195230/1466926.png"),
            http("request_192")
			.get(uri1 + "/22/2195233/1466926.png"),
            http("request_193")
			.get(uri1 + "/22/2195233/1466930.png")))
		.exec(http("request_194")
			.get("/22/2195234/1466928.png")
			.resources(http("request_195")
			.get(uri1 + "/22/2195234/1466929.png"),
            http("request_196")
			.get(uri1 + "/22/2195234/1466930.png"),
            http("request_197")
			.get(uri1 + "/22/2195232/1466931.png"),
            http("request_198")
			.get(uri1 + "/22/2195231/1466931.png"),
            http("request_199")
			.get(uri1 + "/22/2195233/1466931.png"),
            http("request_200")
			.get(uri1 + "/22/2195234/1466931.png"),
            http("request_201")
			.get(uri1 + "/22/2195233/1466932.png"),
            http("request_202")
			.get(uri1 + "/22/2195234/1466932.png"),
            http("request_203")
			.get(uri1 + "/22/2195232/1466932.png"),
            http("request_204")
			.get(uri1 + "/22/2195234/1466934.png"),
            http("request_205")
			.get(uri1 + "/22/2195234/1466933.png"),
            http("request_206")
			.get(uri1 + "/22/2195235/1466932.png"),
            http("request_207")
			.get(uri1 + "/22/2195235/1466933.png"),
            http("request_208")
			.get(uri1 + "/22/2195235/1466931.png"),
            http("request_209")
			.get(uri1 + "/22/2195233/1466933.png"),
            http("request_210")
			.get(uri1 + "/22/2195233/1466934.png"),
            http("request_211")
			.get(uri1 + "/22/2195235/1466934.png"),
            http("request_212")
			.get(uri1 + "/22/2195236/1466933.png"),
            http("request_213")
			.get(uri1 + "/22/2195236/1466931.png"),
            http("request_214")
			.get(uri1 + "/22/2195236/1466934.png"),
            http("request_215")
			.get(uri1 + "/22/2195236/1466932.png"),
            http("request_216")
			.get(uri1 + "/22/2195235/1466936.png"),
            http("request_217")
			.get(uri1 + "/22/2195234/1466935.png"),
            http("request_218")
			.get(uri1 + "/22/2195235/1466935.png"),
            http("request_219")
			.get(uri1 + "/22/2195236/1466936.png"),
            http("request_220")
			.get(uri1 + "/22/2195234/1466936.png"),
            http("request_221")
			.get(uri1 + "/22/2195236/1466935.png"),
            http("request_222")
			.get(uri1 + "/22/2195235/1466937.png"),
            http("request_223")
			.get(uri1 + "/22/2195236/1466937.png"),
            http("request_224")
			.get(uri1 + "/22/2195237/1466936.png"),
            http("request_225")
			.get(uri1 + "/22/2195237/1466935.png"),
            http("request_226")
			.get(uri1 + "/22/2195236/1466938.png"),
            http("request_227")
			.get(uri1 + "/22/2195237/1466937.png"),
            http("request_228")
			.get(uri1 + "/22/2195235/1466938.png"),
            http("request_229")
			.get(uri1 + "/22/2195237/1466938.png"),
            http("request_230")
			.get(uri1 + "/22/2195237/1466939.png"),
            http("request_231")
			.get(uri1 + "/22/2195236/1466939.png"),
            http("request_232")
			.get(uri1 + "/22/2195236/1466940.png"),
            http("request_233")
			.get(uri1 + "/22/2195238/1466939.png"),
            http("request_234")
			.get(uri1 + "/22/2195238/1466938.png"),
            http("request_235")
			.get(uri1 + "/22/2195235/1466939.png"),
            http("request_236")
			.get(uri1 + "/22/2195237/1466940.png"),
            http("request_237")
			.get(uri1 + "/22/2195238/1466937.png"),
            http("request_238")
			.get(uri1 + "/22/2195235/1466940.png"),
            http("request_239")
			.get(uri1 + "/22/2195238/1466940.png"),
            http("request_240")
			.get(uri1 + "/22/2195239/1466941.png"),
            http("request_241")
			.get(uri1 + "/22/2195240/1466940.png"),
            http("request_242")
			.get(uri1 + "/22/2195237/1466941.png"),
            http("request_243")
			.get(uri1 + "/22/2195238/1466941.png"),
            http("request_244")
			.get(uri1 + "/22/2195239/1466940.png"),
            http("request_245")
			.get(uri1 + "/22/2195239/1466939.png"),
            http("request_246")
			.get(uri1 + "/22/2195239/1466942.png"),
            http("request_247")
			.get(uri1 + "/22/2195240/1466941.png"),
            http("request_248")
			.get(uri1 + "/22/2195237/1466942.png"),
            http("request_249")
			.get(uri1 + "/22/2195240/1466939.png"),
            http("request_250")
			.get(uri1 + "/22/2195238/1466942.png"),
            http("request_251")
			.get(uri1 + "/22/2195240/1466942.png"),
            http("request_252")
			.get(uri1 + "/22/2195241/1466942.png"),
            http("request_253")
			.get(uri1 + "/22/2195240/1466943.png"),
            http("request_254")
			.get(uri1 + "/22/2195241/1466943.png"),
            http("request_255")
			.get(uri1 + "/22/2195240/1466944.png"),
            http("request_256")
			.get(uri1 + "/22/2195241/1466941.png"),
            http("request_257")
			.get(uri1 + "/22/2195239/1466943.png"),
            http("request_258")
			.get(uri1 + "/22/2195241/1466940.png"),
            http("request_259")
			.get(uri1 + "/22/2195239/1466944.png"),
            http("request_260")
			.get(uri1 + "/22/2195241/1466944.png"),
            http("request_261")
			.get(uri1 + "/22/2195242/1466942.png"),
            http("request_262")
			.get(uri1 + "/22/2195242/1466943.png"),
            http("request_263")
			.get(uri1 + "/22/2195242/1466941.png"),
            http("request_264")
			.get(uri1 + "/22/2195242/1466940.png"),
            http("request_265")
			.get(uri1 + "/22/2195242/1466944.png"),
            http("request_266")
			.get(uri1 + "/22/2195242/1466945.png"),
            http("request_267")
			.get(uri1 + "/22/2195243/1466942.png"),
            http("request_268")
			.get(uri1 + "/22/2195243/1466943.png"),
            http("request_269")
			.get(uri1 + "/22/2195240/1466945.png"),
            http("request_270")
			.get(uri1 + "/22/2195243/1466944.png"),
            http("request_271")
			.get(uri1 + "/22/2195241/1466945.png"),
            http("request_272")
			.get(uri1 + "/22/2195243/1466945.png")))
		.exec(http("request_273")
			.get("/21/1097621/733472.png")
			.resources(http("request_274")
			.get(uri1 + "/21/1097622/733471.png"),
            http("request_275")
			.get(uri1 + "/21/1097620/733471.png"),
            http("request_276")
			.get(uri1 + "/21/1097620/733472.png"),
            http("request_277")
			.get(uri1 + "/21/1097620/733470.png"),
            http("request_278")
			.get(uri1 + "/21/1097621/733471.png"),
            http("request_279")
			.get(uri1 + "/21/1097619/733471.png"),
            http("request_280")
			.get(uri1 + "/21/1097619/733472.png"),
            http("request_281")
			.get(uri1 + "/21/1097621/733473.png"),
            http("request_282")
			.get(uri1 + "/21/1097621/733470.png"),
            http("request_283")
			.get(uri1 + "/21/1097620/733473.png"),
            http("request_284")
			.get(uri1 + "/21/1097622/733472.png"),
            http("request_285")
			.get(uri1 + "/21/1097619/733473.png"),
            http("request_286")
			.get(uri1 + "/21/1097619/733470.png"),
            http("request_287")
			.get(uri1 + "/21/1097622/733473.png"),
            http("request_288")
			.get(uri1 + "/21/1097622/733470.png"),
            http("request_289")
			.get(uri1 + "/20/548810/366735.png"),
            http("request_290")
			.get(uri1 + "/20/548809/366736.png"),
            http("request_291")
			.get(uri1 + "/20/548809/366735.png"),
            http("request_292")
			.get(uri1 + "/20/548811/366736.png"),
            http("request_293")
			.get(uri1 + "/20/548811/366735.png"),
            http("request_294")
			.get(uri1 + "/20/548810/366736.png"),
            http("request_295")
			.get(uri1 + "/20/548810/366737.png"),
            http("request_296")
			.get(uri1 + "/20/548810/366734.png"),
            http("request_297")
			.get(uri1 + "/20/548809/366737.png"),
            http("request_298")
			.get(uri1 + "/20/548811/366734.png"),
            http("request_299")
			.get(uri1 + "/20/548811/366737.png"),
            http("request_300")
			.get(uri1 + "/19/274406/183368.png"),
            http("request_301")
			.get(uri1 + "/19/274406/183367.png"),
            http("request_302")
			.get(uri1 + "/19/274404/183369.png"),
            http("request_303")
			.get(uri1 + "/19/274403/183369.png"),
            http("request_304")
			.get(uri1 + "/19/274405/183369.png"),
            http("request_305")
			.get(uri1 + "/19/274406/183366.png"),
            http("request_306")
			.get(uri1 + "/19/274406/183369.png"),
            http("request_307")
			.get(uri1 + "/18/137204/91683.png"),
            http("request_308")
			.get(uri1 + "/18/137204/91684.png"),
            http("request_309")
			.get(uri1 + "/18/137204/91682.png"),
            http("request_310")
			.get(uri1 + "/18/137204/91685.png")))
		.exec(http("request_311")
			.get("/15/17148/11459.png")
			.resources(http("request_312")
			.get(uri1 + "/15/17150/11458.png"),
            http("request_313")
			.get(uri1 + "/15/17148/11460.png"),
            http("request_314")
			.get(uri1 + "/15/17148/11461.png"),
            http("request_315")
			.get(uri1 + "/15/17148/11462.png"),
            http("request_316")
			.get(uri1 + "/15/17149/11458.png"),
            http("request_317")
			.get(uri1 + "/15/17148/11458.png"),
            http("request_318")
			.get(uri1 + "/15/17151/11458.png"),
            http("request_319")
			.get(uri1 + "/14/8575/5728.png"),
            http("request_320")
			.get(uri1 + "/14/8574/5728.png"),
            http("request_321")
			.get(uri1 + "/14/8573/5730.png"),
            http("request_322")
			.get(uri1 + "/14/8573/5728.png"),
            http("request_323")
			.get(uri1 + "/14/8573/5731.png"),
            http("request_324")
			.get(uri1 + "/14/8573/5729.png"),
            http("request_325")
			.get(uri1 + "/14/8576/5728.png")))
		.exec(http("request_326")
			.get("/11/1072/714.png")
			.resources(http("request_327")
			.get(uri1 + "/11/1073/714.png"),
            http("request_328")
			.get(uri1 + "/11/1070/714.png"),
            http("request_329")
			.get(uri1 + "/11/1071/714.png")))
		.exec(http("request_330")
			.get("/10/534/356.png"))

	setUp(scn.inject(atOnceUsers(150))).protocols(httpProtocol)
}