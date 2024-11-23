/*
	YouTube media parse
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 									-> get title for UI
// string GetVersion									-> get version for manage
// string GetDesc()										-> get detail information
// string GetLoginTitle()								-> get title for login dialog
// string GetLoginDesc()								-> get desc for login dialog
// string GetUserText()									-> get user text for login dialog
// string GetPasswordText()								-> get password text for login dialog
// string ServerCheck(string User, string Pass) 		-> server check
// string ServerLogin(string User, string Pass) 		-> login
// void ServerLogout() 									-> logout
//------------------------------------------------------------------------------------------------
// bool PlayitemCheck(const string &in)					-> check playitem
// array<dictionary> PlayitemParse(const string &in)	-> parse playitem
// bool PlaylistCheck(const string &in)					-> check playlist
// array<dictionary> PlaylistParse(const string &in)	-> parse playlist

string GetTitle()
{
	return "YouTube with SponsorBlock support";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return "Modified version of the default YouTube Extension that adds SponsorBlock segments as Chapters.\nUses SponsorBlock data from https://sponsor.ajay.app/";
}

string YOUTUBE_MP_URL				= "://www.youtube.com/";
string YOUTUBE_PL_URL				= "://www.youtube.com/playlist?";
string YOUTUBE_USER_URL    			= "://www.youtube.com/user/";
string YOUTUBE_USER_SHORT_URL       = "://www.youtube.com/c/";
string YOUTUBE_CHANNEL_URL			= "://www.youtube.com/channel/";
string YOUTUBE_URL_LIBRARY          = "youtube.com/@";
string YOUTUBE_URL					= "://www.youtube.com/watch?";
string YOUTUBE_URL2					= "://www.youtube.com/v/";
string YOUTUBE_URL3					= "://www.youtube.com/embed/";
string YOUTUBE_URL4					= "://www.youtube.com/attribution_link?a=";
string YOUTUBE_URL5					= "://www.youtube.com/shorts";
string YOUTUBE_URL6					= "://www.youtube.com/clip";
string YOUTU_BE_URL1				= "://youtu.be/";
string YOUTU_BE_URL2				= "://youtube.com/";
string YOUTU_BE_URL3				= "://m.youtube.com/";
string YOUTU_BE_URL4				= "://gaming.youtube.com/";
string YOUTU_BE_URL5				= "://music.youtube.com/";
string VIMEO_URL					= "://vimeo.com/";

string MATCH_STREAM_MAP_START		= "\"url_encoded_fmt_stream_map\"";
string MATCH_STREAM_MAP_START2		= "url_encoded_fmt_stream_map=";
string MATCH_ADAPTIVE_FMTS_START	= "\"adaptive_fmts\"";
string MATCH_ADAPTIVE_FMTS_START2	= "adaptive_fmts=";
string MATCH_HLSMPD_START			= "hlsManifestUrl";
string MATCH_DASHMPD_START			= "dashManifestUrl";
string MATCH_WIDTH_START			= "meta property=\"og:video:width\" content=\"";
string MATCH_JS_START				= "\"js\":";
string MATCH_JS_START_2             = "'PREFETCH_JS_RESOURCES': [\"";
string MATCH_JS_START_3             = "\"PLAYER_JS_URL\":\"";
string MATCH_END					= "\"";
string MATCH_END2					= "&";

string MATCH_PLAYER_RESPONSE       = "\"player_response\":\"";
string MATCH_PLAYER_RESPONSE2      = "player_response=";
string MATCH_PLAYER_RESPONSE_END   = "}\"";

string MATCH_PLAYER_RESPONSE_2     = "ytInitialPlayerResponse = ";

string MATCH_CHAPTER_RESPONSE      = "chapteredPlayerBarRenderer";
string MATCH_CHAPTER_RESPONSE2     = "key\":\"DESCRIPTION_CHAPTERS\",\"value\"";

bool Is60Frame(int iTag)
{
	return iTag == 272 || iTag == 298 || iTag == 299 || iTag == 300 || iTag == 301 || iTag == 302 || iTag == 303 || iTag == 308 || iTag == 315 || iTag == 334 || iTag == 335 || iTag == 336 || iTag == 337;
}

bool IsHDR(int iTag)
{
	return iTag >= 330 && iTag <= 337 || iTag >= 694 && iTag <= 702;
}

bool IsTag3D(int iTag)
{
	return (iTag >= 82 && iTag <= 85) || (iTag >= 100 && iTag <= 102);
}

enum ytype
{
	y_unknown,
	y_mp4,
	y_webm,
	y_flv,
	y_3gp,
	y_3d_mp4,
	y_3d_webm,
	y_apple_live,
	y_dash_mp4_video,
	y_dash_mp4_audio,
	y_webm_video,
	y_webm_audio,
};

class YOUTUBE_PROFILES
{
	int iTag;
	ytype type;
	int quality;
	string ext;

	YOUTUBE_PROFILES(int _iTag, ytype _type, int _quality, string _ext)
	{
		iTag = _iTag;
		type = _type;
		quality = _quality;
		ext = _ext;
	}
	YOUTUBE_PROFILES()
	{
	}
};

array<YOUTUBE_PROFILES> youtubeProfiles =
{
	YOUTUBE_PROFILES(22, y_mp4, 720, "mp4"),
	YOUTUBE_PROFILES(37, y_mp4, 1080, "mp4"),
	YOUTUBE_PROFILES(38, y_mp4, 3072, "mp4"),
	YOUTUBE_PROFILES(18, y_mp4, 360, "mp4"),

	YOUTUBE_PROFILES(45, y_webm, 720, "webm"),
	YOUTUBE_PROFILES(46, y_webm, 1080, "webm"),
	YOUTUBE_PROFILES(44, y_webm, 480, "webm"),
	YOUTUBE_PROFILES(43, y_webm, 360, "webm"),

	YOUTUBE_PROFILES(120, y_flv, 720, "flv"),
	YOUTUBE_PROFILES(35, y_flv, 480, "flv"),
	YOUTUBE_PROFILES(34, y_flv, 360, "flv"),
	YOUTUBE_PROFILES(6, y_flv, 270, "flv"),
	YOUTUBE_PROFILES(5, y_flv, 240, "flv"),

	YOUTUBE_PROFILES(36, y_3gp, 240, "3gp"),
	YOUTUBE_PROFILES(13, y_3gp, 144, "3gp"),
	YOUTUBE_PROFILES(17, y_3gp, 144, "3gp"),
};

array<YOUTUBE_PROFILES> youtubeProfilesExt =
{
//	3d
	YOUTUBE_PROFILES(84, y_3d_mp4, 720, "mp4"),
	YOUTUBE_PROFILES(85, y_3d_mp4, 520, "mp4"),
	YOUTUBE_PROFILES(83, y_3d_mp4, 480, "mp4"),
	YOUTUBE_PROFILES(82, y_3d_mp4, 360, "mp4"),

// 	live
	YOUTUBE_PROFILES(267, y_mp4,  2160, "mp4"),
	YOUTUBE_PROFILES(265, y_mp4,  1440, "mp4"),
	YOUTUBE_PROFILES(301, y_mp4, 1080, "mp4"),
	YOUTUBE_PROFILES(300, y_mp4,  720, "mp4"),
	YOUTUBE_PROFILES(96, y_mp4, 1080, "mp4"),
	YOUTUBE_PROFILES(95, y_mp4,  720, "mp4"),
	YOUTUBE_PROFILES(94, y_mp4,  480, "mp4"),
	YOUTUBE_PROFILES(93, y_mp4,  360, "mp4"),
	YOUTUBE_PROFILES(92, y_mp4,  240, "mp4"),

// 	av1
	YOUTUBE_PROFILES(571, y_dash_mp4_video, 4320, "mp4"),
	YOUTUBE_PROFILES(402, y_dash_mp4_video, 4320, "mp4"),
	YOUTUBE_PROFILES(401, y_dash_mp4_video, 2160, "mp4"),
	YOUTUBE_PROFILES(400, y_dash_mp4_video, 1440, "mp4"),
	YOUTUBE_PROFILES(399, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(398, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(397, y_dash_mp4_video, 480, "mp4"),
	YOUTUBE_PROFILES(396, y_dash_mp4_video, 360, "mp4"),
	YOUTUBE_PROFILES(395, y_dash_mp4_video, 240, "mp4"),
	YOUTUBE_PROFILES(394, y_dash_mp4_video, 144, "mp4"),

//	av1 hdr
	YOUTUBE_PROFILES(702, y_dash_mp4_video, 4320, "mp4"),
	YOUTUBE_PROFILES(701, y_dash_mp4_video, 2160, "mp4"),
	YOUTUBE_PROFILES(700, y_dash_mp4_video, 1440, "mp4"),
	YOUTUBE_PROFILES(699, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(698, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(697, y_dash_mp4_video, 480, "mp4"),
	YOUTUBE_PROFILES(696, y_dash_mp4_video, 360, "mp4"),
	YOUTUBE_PROFILES(695, y_dash_mp4_video, 240, "mp4"),
	YOUTUBE_PROFILES(694, y_dash_mp4_video, 144, "mp4"),

	YOUTUBE_PROFILES(102, y_webm_video, 720, "webm"),
	YOUTUBE_PROFILES(100, y_webm_video, 360, "webm"),
	YOUTUBE_PROFILES(101, y_webm_video, 360, "webm"),

// 	dash
	YOUTUBE_PROFILES(266, y_dash_mp4_video, 2160, "mp4"),
	YOUTUBE_PROFILES(138, y_dash_mp4_video, 2160, "mp4"), // 8K도 이걸로 될 수 있다.. ㄷㄷ
	YOUTUBE_PROFILES(264, y_dash_mp4_video, 1440, "mp4"),
	YOUTUBE_PROFILES(137, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(136, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(135, y_dash_mp4_video, 480, "mp4"),
	YOUTUBE_PROFILES(134, y_dash_mp4_video, 360, "mp4"),
	YOUTUBE_PROFILES(133, y_dash_mp4_video, 240, "mp4"),
	YOUTUBE_PROFILES(160, y_dash_mp4_video, 144, "mp4"),
	YOUTUBE_PROFILES(139, y_dash_mp4_audio, 64, "m4a"),
	YOUTUBE_PROFILES(140, y_dash_mp4_audio, 128, "m4a"),
	YOUTUBE_PROFILES(141, y_dash_mp4_audio, 256, "m4a"),
	YOUTUBE_PROFILES(256, y_dash_mp4_audio, 192, "m4a"),
	YOUTUBE_PROFILES(258, y_dash_mp4_audio, 384, "m4a"),
	YOUTUBE_PROFILES(327, y_dash_mp4_audio, 320, "m4a"),

	YOUTUBE_PROFILES(380, y_dash_mp4_audio, 384, "m4a"), // AC3
	YOUTUBE_PROFILES(328, y_dash_mp4_audio,	384, "m4a"), // E-AC3
	YOUTUBE_PROFILES(325, y_dash_mp4_audio,	384, "m4a"), // DTS-Express

	YOUTUBE_PROFILES(272, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(271, y_webm_video, 1440, "webm"),
	YOUTUBE_PROFILES(248, y_webm_video, 1080, "webm"),
	YOUTUBE_PROFILES(247, y_webm_video, 720, "webm"),
	YOUTUBE_PROFILES(244, y_webm_video, 480, "webm"),
	YOUTUBE_PROFILES(243, y_webm_video, 360, "webm"),
	YOUTUBE_PROFILES(242, y_webm_video, 240, "webm"),
	YOUTUBE_PROFILES(278, y_webm_video, 144, "webm"),

	YOUTUBE_PROFILES(171, y_webm_audio, 128, "webm"),
	YOUTUBE_PROFILES(172, y_webm_audio, 192, "webm"),
	YOUTUBE_PROFILES(338, y_webm_audio, 256, "webm"),
	YOUTUBE_PROFILES(339, y_webm_audio, 320, "webm"),

	YOUTUBE_PROFILES(249, y_webm_audio, 48,  "webm"), // opus
	YOUTUBE_PROFILES(250, y_webm_audio, 64, "webm"), // opus
	YOUTUBE_PROFILES(251, y_webm_audio, 256, "webm"), // opus
	YOUTUBE_PROFILES(338, y_webm_audio, 128, "webm"), // opus

	YOUTUBE_PROFILES(313, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(314, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(302, y_webm_video, 720, "webm"),

	// 60p
	YOUTUBE_PROFILES(315, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(308, y_webm_video, 1440, "webm"),
	YOUTUBE_PROFILES(303, y_webm_video, 1080, "webm"),

	// HDR
	YOUTUBE_PROFILES(330, y_webm_video, 144, "webm"),
	YOUTUBE_PROFILES(331, y_webm_video, 240, "webm"),
	YOUTUBE_PROFILES(332, y_webm_video, 360, "webm"),
	YOUTUBE_PROFILES(333, y_webm_video, 480, "webm"),
	YOUTUBE_PROFILES(334, y_webm_video, 720, "webm"),
	YOUTUBE_PROFILES(335, y_webm_video, 1080, "webm"),
	YOUTUBE_PROFILES(336, y_webm_video, 1440, "webm"),
	YOUTUBE_PROFILES(337, y_webm_video, 2160, "webm"),

	// 60P
	YOUTUBE_PROFILES(298, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(299, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(304, y_dash_mp4_video, 1440, "mp4"),
};

int GetYouTubeQuality(int iTag)
{
	for (int i = 0, len = youtubeProfiles.size(); i < len; i++)
	{
		if (iTag == youtubeProfiles[i].iTag) return youtubeProfiles[i].quality;
	}

	for (int i = 0, len = youtubeProfilesExt.size(); i < len; i++)
	{
		if (iTag == youtubeProfilesExt[i].iTag) return youtubeProfilesExt[i].quality;
	}

	return 0;
}

ytype GetYouTubeType(int iTag)
{
	for (int i = 0, len = youtubeProfiles.size(); i < len; i++)
	{
		if (iTag == youtubeProfiles[i].iTag) return youtubeProfiles[i].type;
	}

	for (int i = 0, len = youtubeProfilesExt.size(); i < len; i++)
	{
		if (iTag == youtubeProfilesExt[i].iTag) return youtubeProfilesExt[i].type;
	}

	return y_unknown;
}

YOUTUBE_PROFILES getProfile(int iTag, bool ext = false)
{
	for (int i = 0, len = youtubeProfiles.size(); i < len; i++)
	{
		if (iTag == youtubeProfiles[i].iTag) return youtubeProfiles[i];
	}

	if (ext)
	{
		for (int i = 0, len = youtubeProfilesExt.size(); i < len; i++)
		{
			if (iTag == youtubeProfilesExt[i].iTag) return youtubeProfilesExt[i];
		}
	}

	YOUTUBE_PROFILES youtubeProfileEmpty(0, y_unknown, 0, "");
	return youtubeProfileEmpty;
}

bool SelectBestProfile(int &itag_final, string &ext_final, int itag_current, YOUTUBE_PROFILES sets)
{
	YOUTUBE_PROFILES current = getProfile(itag_current);

	if (current.iTag <= 0 || current.type != sets.type || current.quality > sets.quality)
	{
		return false;
	}

	if (itag_final != 0)
	{
		YOUTUBE_PROFILES fin = getProfile(itag_final);

		if (current.quality < fin.quality) return false;
	}

	itag_final = current.iTag;
	ext_final = "." + current.ext;

	return true;
}

bool SelectBestProfile2(int &itag_final, string &ext_final, int itag_current, YOUTUBE_PROFILES sets)
{
	YOUTUBE_PROFILES current = getProfile(itag_current, true);

	if (current.iTag <= 0 || current.quality > sets.quality)
	{
		return false;
	}

	if (itag_final != 0)
	{
		YOUTUBE_PROFILES fin = getProfile(itag_final, true);

		if (current.quality < fin.quality) return false;
	}

	itag_final = current.iTag;
	ext_final = "." + current.ext;

	return true;
}

class QualityListItem
{
	string url;
	string quality;
	string qualityDetail;
	string resolution;
	string bitrate;
	string format;
	int itag = 0;
	double fps = 0.0;
	int type3D = 0; // 1:sbs, 2:t&b
	bool is360 = false;
	bool isHDR = false;
	string audioName;
	string audioCode;
	int bitrateVal = 0;

	dictionary toDictionary()
	{
		dictionary ret;

		ret["url"] = url;
		ret["quality"] = quality;
		ret["qualityDetail"] = qualityDetail;
		ret["resolution"] = resolution;
		ret["bitrate"] = bitrate;
		ret["format"] = format;
		ret["itag"] = itag;
		ret["fps"] = fps;
		ret["type3D"] = type3D;
		ret["is360"] = is360;
		ret["isHDR"] = isHDR;
		ret["audioName"] = audioName;
		ret["audioCode"] = audioCode;
		ret["bitrateVal"] = bitrateVal;
		return ret;
	}
};

void AppendQualityList(array<dictionary> &QualityList, QualityListItem &item, string url)
{
	YOUTUBE_PROFILES pPro = getProfile(item.itag, true);

	if (pPro.iTag > 0)
	{
		bool Detail = false;

		if (Is60Frame(item.itag) && item.fps < 1) item.fps = 60.0;
		if (!url.empty()) item.url = url;
		if (item.format.empty()) item.format = pPro.ext;
		if (item.quality.empty())
		{
			if (pPro.type == y_dash_mp4_audio || pPro.type == y_webm_audio)
			{
				string quality = formatInt(pPro.quality) + "K";
				if (item.bitrate.empty()) item.quality = quality;
				else item.quality = item.bitrate;
			}
			else
			{
				Detail = true;
				if (!item.bitrate.empty())
				{
					if (!item.resolution.empty())
					{
						int p = item.resolution.find("x");

						if (p > 0)
						{
							item.quality = item.resolution.substr(p + 1);
							item.quality += "P";
						}
					}
				}
			}
		}
		else Detail = true;
		string Quality = item.quality;
		string QualityDetail = item.qualityDetail;
		if (Detail && !item.bitrate.empty()) item.quality = item.bitrate + ", " + item.quality;

		bool Res = false;
		if (item.qualityDetail.empty())
		{
			item.qualityDetail = item.quality;
			Res = true;
		}
		else if (Detail && !Quality.empty() && item.qualityDetail != Quality) item.qualityDetail += "(" + Quality + ")";
		if (Detail)
		{
			bool add = true;

			if (Res)
			{
				if (item.resolution.empty())
				{
					if (pPro.type == y_dash_mp4_audio || pPro.type == y_webm_audio) add = false;
					else item.qualityDetail = formatInt(pPro.quality) + "P";
				}
				else item.qualityDetail = item.resolution;
			}
			if (add && !item.bitrate.empty()) item.qualityDetail = item.bitrate + ", " + item.qualityDetail;
			if (!QualityDetail.empty())
			{
				item.quality = QualityDetail;
				if (!item.bitrate.empty()) item.quality = item.bitrate + ", " + item.quality;
			}
		}
		for (int i = 0; i < QualityList.size(); i++)
		{
			int itag = 0;
			string audioCode;
			
			QualityList[i].get("itag", itag);
			QualityList[i].get("audioCode", audioCode);
			if (((pPro.type == y_dash_mp4_audio && GetYouTubeType(itag) == y_dash_mp4_audio) || (pPro.type == y_webm_audio && GetYouTubeType(itag) == y_webm_audio)) && audioCode == item.audioCode)
			{
				int bitrateVal = 0;
				
				QualityList[i].get("bitrateVal", bitrateVal);
				if (item.bitrateVal > bitrateVal) QualityList[i] = item.toDictionary();
				return;
			}		
			else if (itag == item.itag && audioCode == item.audioCode)
			{
				string format, resolution, quality, qualityDetail;

				QualityList[i].get("format", format);
				QualityList[i].get("resolution", resolution);
				QualityList[i].get("quality", quality);
				QualityList[i].get("qualityDetail", qualityDetail);
				if (format.size() < item.format.size()) QualityList[i]["format"] = item.format;
				if (resolution.size() < item.resolution.size()) QualityList[i]["resolution"] = item.resolution;
				if (quality.size() < item.quality.size()) QualityList[i]["quality"] = item.quality;
				if (qualityDetail.size() < item.qualityDetail.size()) QualityList[i]["qualityDetail"] = item.qualityDetail;
				QualityList[i]["url"] = item.url;
				QualityList[i]["audioCode"] = item.audioCode;
				return;
			}
		}
		QualityList.insertLast(item.toDictionary());
	}
	else
	{
		HostPrintUTF8("  *unknown itag: " + formatInt(item.itag) + "\n");
	}
}

string GetEntry(string &pszBuff, string pszMatchStart, string pszMatchEnd)
{
	int Start = pszBuff.find(pszMatchStart);

	if (Start >= 0)
	{
		Start += pszMatchStart.size();
		int End = pszBuff.find(pszMatchEnd, Start);
		if (End > Start) return pszBuff.substr(Start, End - Start);
		else
		{
			End = pszBuff.size();
			return pszBuff.substr(Start, End - Start);
		}
	}

	return "";
}

void GetEntrys(string pszBuff, string pszMatchStart, string pszMatchEnd, array<string> &pEntrys)
{
	while (true)
	{
		string entry = GetEntry(pszBuff, pszMatchStart, pszMatchEnd);

		if (entry.empty()) break;
		else
		{
			pEntrys.insertLast(entry);

			int Start = pszBuff.find(pszMatchStart);
			if (Start >= 0)
			{
				Start += pszMatchStart.size();
				pszBuff = pszBuff.substr(Start, pszBuff.size() - Start);
			}
			else break;
		}
	}
}

string RepleaceYouTubeUrl(string url)
{
	if (url.find(YOUTU_BE_URL1) >= 0) url.replace(YOUTU_BE_URL1, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL2) >= 0) url.replace(YOUTU_BE_URL2, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL3) >= 0) url.replace(YOUTU_BE_URL3, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL4) >= 0) url.replace(YOUTU_BE_URL4, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL5) >= 0) url.replace(YOUTU_BE_URL5, YOUTUBE_MP_URL);
	
	if (url.find(YOUTUBE_URL2) >= 0 || url.find(YOUTUBE_URL3) >= 0 || url.find(YOUTUBE_URL4) >= 0 || url.find(YOUTUBE_URL5) >= 0 || url.find(YOUTUBE_URL6) >= 0)
	{
		int p = url.rfind("/");

		if (p >= 0)
		{
			string id = url.substr(p + 1);

			url = "http" + YOUTUBE_URL + "v=" + id;
		}
	}
	
	return url;
}

string MakeYouTubeUrl(string url)
{
	if (url.find("watch?v=") < 0 && url.find("&v=") < 0)
	{
		url.replace("watch?", "watch?v=");
		if (url.find("watch?v=") < 0)
		{
			int p = url.rfind("/");

			if (p > 0) url.insert(p + 1, "watch?v=");
		}
	}
	return url;
}

string CorrectURL(string url)
{
	int p = url.find("http");
	if (p > 0) url.erase(0, p);
	p = url.find("\"");
	if (p > 0) url = url.substr(0, p);
	return url;
}

string PlayerYouTubeSearchJS(string data)
{
	string find1 = "html5player.js";
	int s = data.find(find1);

	if (s >= 0)
	{
		int e = s + find1.size();
		bool found = false;

		while (s > 0)
		{
			if (data.substr(s, 1) == "\"")
			{
				s++;
				found = true;
				break;
			}
			s--;
		}
		if (found)
		{
			string ret = data.substr(s, e - s);

			return ret;
		}
	}

	s = data.find(MATCH_JS_START);
	if (s >= 0)
	{
		s += 6;
		int e = data.find(".js", s);

		if (e > s)
		{
			string ret = data.substr(s, e + 3 - s);

			ret.Trim();
			ret.Trim("\"");
			return ret;
		}
	}

	s = data.find("/jsbin/player-");
	if (s >= 0)
	{
		s += 6;
		int e = data.find(".js", s);

		while (s > 0)
		{
			if (data.substr(s, 1) == "\"") break;
			else s--;
		}
		if (e > s)
		{
			string ret = data.substr(s, e + 3 - s);

			ret.Trim();
			ret.Trim("\"");
			return ret;
		}
	}

	return "";
}

enum youtubeFuncType
{
	funcNONE = -1,
	funcDELETE,
	funcREVERSE,
	funcSWAP
};

void Delete(string &a, int b)
{
	a.erase(0, b);
}

void Swap(string &a, int b)
{
	uint8 c = a[0];

	b %= a.size();
	a[0] = a[b];
	a[b] = c;
};

void Reverse(string &a)
{
	int len = a.size();

	for (int i = 0; i < len / 2; ++i)
	{
		uint8 c = a[i];

		a[i] = a[len - i - 1];
		a[len - i - 1] = c;
	}
}

string ReplaceCodecName(string name, string id)
{
	int s = name.find(id);

	if (s > 0)
	{
		int e = name.find(")", s);

		if (e < 0) e = name.find(",", s);
		if (e < 0) e = name.find("/", s);
		if (e < 0) e = name.size();
		s += id.size();
		name.erase(s, e - s);
	}
	return name;
}

string GetCodecName(string type)
{
	type.replace(",+", "/");
	type.replace(";+", " ");
	type.replace("video/", "");
	type.replace("audio/", "");
	type.replace(" codecs=", ", ");
	type.replace("\"", "");
	type.replace("x-flv", "flv");
	type = ReplaceCodecName(type, "avc");
	type = ReplaceCodecName(type, "av01");
	type = ReplaceCodecName(type, "mp4v");
	type = ReplaceCodecName(type, "mp4a");

	return type;
}

string GetFunction(string str)
{
	array<string> signatureRegExps =
	{
		"(?:\\b|[^a-zA-Z0-9$])([a-zA-Z0-9$]{2,})\\s*=\\s*function\\(\\s*a\\s*\\)\\s*\\{\\s*a\\s*=\\s*a\\.split\\(\\s*\"\"\\s*\\)",
		"(?:\\b|[^a-zA-Z0-9$])([a-zA-Z0-9$]{2,})\\s*=\\s*function\\(\\s*a\\s*\\)\\s*\\{\\s*a\\s*=\\s*a\\.split\\(\\s*\"\"\\s*\\);[a-zA-Z0-9$]{2}\\.[a-zA-Z0-9$]{2}\\(a,\\d+\\)",
		"\\b[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*encodeURIComponent\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"\\b[a-zA-Z0-9]+\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*encodeURIComponent\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"([a-zA-Z0-9$]+)\\s*=\\s*function\\(\\s*a\\s*\\)\\s*\\{\\s*a\\s*=\\s*a\\.split\\(\\s*\"\"\\s*\\)",
		"([\"\\'])signature\\1\\s*,\\s*([a-zA-Z0-9$]+)\\(",
		"\\.sig\\|\\|([a-zA-Z0-9$]+)\\(",
		"yt\\.akamaized\\.net/\\)\\s*\\|\\|\\s*.*?\\s*[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*(?:encodeURIComponent\\s*\\()?\\s*([a-zA-Z0-9$]+)\\(",
		"\\b[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*([a-zA-Z0-9$]+)\\(",
		"\\b[a-zA-Z0-9]+\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*([a-zA-Z0-9$]+)\\(",
		"\\bc\\s*&&\\s*a\\.set\\([^,]+\\s*,\\s*\\([^)]*\\)\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"\\bc\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*\\([^)]*\\)\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"\\bc\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*\\([^)]*\\)\\s*\\(\\s*([a-zA-Z0-9$]+)\\("
	};
	for (int i = 0, len = signatureRegExps.size(); i < len; i++)
	{
		string ret = HostRegExpParse(str, signatureRegExps[i]);
		if (!ret.empty()) return ret;
	}

	string r, sig = "\"signature\"";
	int p = 0;
	while (true)
	{
		int e = str.find(sig, p);

		if (e < 0) break;
		int s1 = str.find("(", e);
		int s2 = str.find(")", e);
		if (s1 > s2)
		{
			p = e + 10;
			continue;
		}
		p = e + sig.size() + 1;
		r = str.substr(p, s1 - p);
		break;
	}
	r.Trim(",");
	r.Trim();
	r.Trim(",");
	r.Trim();
	return r;
}

string SignatureDecode(string url, string signature, string append, string data, string js_data, array<youtubeFuncType> &JSFuncs, array<int> &JSFuncArgs)
{
	if (JSFuncs.size() == 0 && !js_data.empty())
	{
		string funcName = GetFunction(js_data);

		if (!funcName.empty())
		{
			string funcRegExp = funcName + "=function\\(a\\)\\{([^\\n]+)\\};";
			string funcBody = HostRegExpParse(data, funcRegExp);

			if (funcBody.empty())
			{
				string varfunc = funcName + "=function(a){";

				funcBody = GetEntry(js_data, varfunc, "};");
			}
			if (!funcBody.empty())
			{
				string funcGroup;
				array<string> funcList;
				array<string> funcCodeList;

				array<string> code = funcBody.split(";");
				for (int i = 0, len = code.size(); i < len; i++)
				{
					string line = code[i];

					if (!line.empty())
					{
						if (line.find("split") >= 0 || line.find("return") >= 0) continue;
						funcList.insertLast(line);
						if (funcGroup.empty())
						{
							int k = line.find(".");

							if (k > 0) funcGroup = line.Left(k);
						}
					}
				}

				if (!funcGroup.empty())
				{
					string tmp = GetEntry(js_data, "var " + funcGroup + "={", "};");

					if (!tmp.empty())
					{
						tmp.replace("\n", "");
						funcCodeList = tmp.split("},");
					}
				}

				if (!funcList.empty() && !funcCodeList.empty())
				{
					for (int j = 0, len = funcList.size(); j < len; j++)
					{
						string func = funcList[j];

						if (!func.empty())
						{
							int funcArg = 0;
							string funcArgs = GetEntry(func, "(", ")");
							array<string> args = funcArgs.split(",");

							if (args.size() >= 1)
							{
								string arg = args[args.size() - 1];

								funcArg = parseInt(arg);
							}

							string funcName = GetEntry(func, funcGroup + '.', "(");
							if (funcName.empty())
							{
								funcName = GetEntry(func, funcGroup, "(");
								if (funcName.empty()) continue;
							}
							if (funcName.find("[") >= 0)
							{
								funcName.replace("[", "");
								funcName.replace("]", "");
							}
							funcName += ":function";

							youtubeFuncType funcType = youtubeFuncType::funcNONE;
							for (int k = 0, len = funcCodeList.size(); k < len; k++)
							{
								string funcCode = funcCodeList[k];

								if (funcCode.find(funcName) >= 0)
								{
									if (funcCode.find("splice") > 0) funcType = youtubeFuncType::funcDELETE;
									else if (funcCode.find("reverse") > 0) funcType = youtubeFuncType::funcREVERSE;
									else if (funcCode.find(".length]") > 0) funcType = youtubeFuncType::funcSWAP;
									break;
								}
							}
							if (funcType != youtubeFuncType::funcNONE)
							{
								JSFuncs.insertLast(funcType);
								JSFuncArgs.insertLast(funcArg);
							}
						}
					}
				}
			}
		}
	}

	if (!JSFuncs.empty() && JSFuncs.size() == JSFuncArgs.size())
	{
		for (int i = 0, len = JSFuncs.size(); i < len; i++)
		{
			youtubeFuncType func = JSFuncs[i];
			int arg = JSFuncArgs[i];

			switch (func)
			{
			case youtubeFuncType::funcDELETE:
				Delete(signature, arg);
				break;
			case youtubeFuncType::funcSWAP:
				Swap(signature, arg);
				break;
			case youtubeFuncType::funcREVERSE:
				Reverse(signature);
				break;
			}
		}
		url = url + append + signature;
	}

	return url;
}

bool PlayerYouTubeCheck(string url)
{
	url.MakeLower();
	if (url.find(YOUTUBE_MP_URL) >= 0 && (url.find("watch?") < 0 || url.find("playlist?") >= 0 || url.find("&list=") >= 0))
	{
		if (url.find(YOUTUBE_URL) >= 0) return true;
		if (url.find(YOUTUBE_URL2) >= 0) return true;
		if (url.find(YOUTUBE_URL3) >= 0) return true;
		if (url.find(YOUTUBE_URL4) >= 0) return true;
		if (url.find(YOUTUBE_URL5) >= 0) return true;
		if (url.find(YOUTUBE_URL6) >= 0) return true;		
		return false;
	}
	if (url.find(YOUTUBE_URL) >= 0 || url.find(YOUTU_BE_URL1) >= 0 || url.find(YOUTU_BE_URL2) >= 0 || url.find(YOUTU_BE_URL3) >= 0 || url.find(YOUTU_BE_URL4) >= 0 || url.find(YOUTU_BE_URL5) >= 0)
	{
		return true;
	}
	return false;
}

string GetVideoID(string url)
{
	string videoId = HostRegExpParse(url, "v=([-a-zA-Z0-9_]+)");
	if (videoId.empty()) videoId = HostRegExpParse(url, "video_ids=([-a-zA-Z0-9_]+)");
	return videoId;
}

bool PlayitemCheck(const string &in path)
{
	if (PlayerYouTubeCheck(path))
	{
		string url = RepleaceYouTubeUrl(path);
		url = MakeYouTubeUrl(url);

		string videoId = GetVideoID(url);
		return !videoId.empty();
	}
	return false;
}

string TrimFloatString(string str)
{
	str.TrimRight("0");
	str.TrimRight(".");
	return str;
}

string GetBitrateString(int64 val)
{
	string ret;

	if (val >= 1000 * 1000)
	{
		val = val / 1000;
		ret = formatFloat(val / 1000.0, "", 0, 1);
		ret = TrimFloatString(ret);
		ret += "M";
	}
	else if (val >= 1000)
	{
		ret = formatFloat(val / 1000.0, "", 0, 1);
		ret = TrimFloatString(ret);
		ret += "K";
	}
	else ret = formatInt(val);
	return ret;
}

string XMLAttrValue(XMLElement Element, string name)
{
	string ret;
	XMLAttribute Attr = Element.FindAttribute(name);

	if (Attr.isValid()) ret = Attr.asString();
	return ret;
}

string GetUserAgent()
{
	return "GooglePlayer";
}

string GetJsonCode(string data, string code, int pos = 0)
{
	int start = data.find(code, pos);

	if (start >= 0)
	{
		int count = 0;
		int len = data.size();
		bool IsString = false;

		start += code.size();
		while (start < len && data.substr(start, 1) != "{") start++;

		int end = start;
		while (end < len)
		{
			string ch = data.substr(end, 1);

			if (ch == "\"")
			{
				string prev = data.substr(end - 1, 1);

				if (prev != "\\") IsString = !IsString;
			}
			if (!IsString)
			{
				if (ch == "{") count++;
				else if (ch == "}") count--;
			}
			end++;
			if (count == 0) break;
		}
		if (end > start) return data.substr(start, end - start);
	}
	return "";
}

string GetVideoJson(string videoId, bool passAge)
{
	string Headers = "X-YouTube-Client-Name: 28\r\nX-YouTube-Client-Version: 1.60.19\r\nOrigin: https://www.youtube.com\r\ncontent-type: application/json\r\n";
	string postData = "{\"context\": {\"client\": {\"clientName\": \"ANDROID_VR\", \"clientVersion\": \"1.60.19\", \"hl\": \"" + HostIso639LangName() + "\"}}, \"videoId\": \"" + videoId + "\", \"params\": \"wgYCCAA=\", \"playbackContext\": {\"contentPlaybackContext\": {\"html5Preference\": \"HTML5_PREF_WANTS\"}}, \"contentCheckOk\": true, \"racyCheckOk\": true}";
	string postData2 = "{\"context\": {\"client\": {\"clientName\": \"ANDROID_VR\", \"clientVersion\": \"1.60.19\", \"clientScreen\": \"EMBED\"}, \"thirdParty\": {\"embedUrl\": \"https://google.com\"}}, \"videoId\": \"" + videoId + "\", \"params\": \"wgYCCAA=\", \"contentCheckOk\": true, \"racyCheckOk\": true}";
	
	return HostUrlGetStringWithAPI("https://www.youtube.com/youtubei/v1/player", "com.google.android.apps.youtube.vr.oculus/1.60.19 (Linux; U; Android 12L; eureka-user Build/SQ3A.220605.009.A1) gzip", Headers, passAge ? postData2 : postData, true);
}

string PlayitemParse(const string &in path, dictionary &MetaData, array<dictionary> &QualityList)
{
//HostOpenConsole();

	if (PlayitemCheck(path))
	{
		string fn = path;
		string tmp_fn = fn;
		array<youtubeFuncType> JSFuncs;
		array<int> JSFuncArgs;

		tmp_fn.MakeLower();
		if (tmp_fn.find(YOUTUBE_URL2) >= 0 || tmp_fn.find(YOUTUBE_URL3) >= 0 || tmp_fn.find(YOUTUBE_URL4) >= 0 || tmp_fn.find(YOUTUBE_URL5) >= 0 || tmp_fn.find(YOUTUBE_URL6) >= 0) fn = RepleaceYouTubeUrl(fn);

		int iYoutubeTag = 22;
		YOUTUBE_PROFILES youtubeSets = getProfile(iYoutubeTag);
		if (youtubeSets.iTag == 0) youtubeSets = getProfile(22);

		string linkWeb = RepleaceYouTubeUrl(fn);
		linkWeb = MakeYouTubeUrl(linkWeb);

		string videoId = GetVideoID(linkWeb);
		linkWeb.replace("http://", "https://");

		if (@MetaData !is null) MetaData["vid"] = videoId;

		string WebData;
		string js_data;

		linkWeb += "&gl=US&hl=en&has_verified=1&bpctr=9999999999";
		WebData = HostUrlGetString(linkWeb, GetUserAgent());

		// Load js
		if (js_data.empty() && (@QualityList !is null) && !WebData.empty())
		{
			string jsUrl = PlayerYouTubeSearchJS(WebData);
			string sts;

			if (jsUrl.empty()) jsUrl = GetEntry(WebData, MATCH_JS_START_2, MATCH_END);
			if (jsUrl.empty()) jsUrl = GetEntry(WebData, MATCH_JS_START_3, MATCH_END);
			if (jsUrl.empty())
			{
				string link = "https://www.youtube.com/embed/" + videoId;
				string JSData = HostUrlGetString(link, GetUserAgent());

				if (!JSData.empty())
				{
					jsUrl = PlayerYouTubeSearchJS(JSData);
					if (jsUrl.empty()) jsUrl = GetEntry(JSData, MATCH_JS_START_2, MATCH_END);
					if (jsUrl.empty()) jsUrl = GetEntry(JSData, MATCH_JS_START_3, MATCH_END);
					sts = HostRegExpParse(JSData, "\"sts\"\\s*:\\s*(\\d+)");
				}
			}
			if (!jsUrl.empty())
			{
				jsUrl.replace("\\/", "/");
				if (jsUrl.find("//") == 0)
				{
					int p = fn.find("//");

					if (p > 0) jsUrl = fn.substr(0, p) + jsUrl;
				}
				if (jsUrl.find("://") < 0) jsUrl = "https://www.youtube.com" + jsUrl;
			}
			if (jsUrl.empty()) jsUrl = "https://www.youtube.com/yts/jsbin/player-ko_KR-vflHE7FfV/base.js";

			js_data = HostUrlGetString(jsUrl, GetUserAgent());
		}

		string error_message;
		string player_response_jsonData, player_chapter_jsonData, player_sponsors_jsonData;
		for (int i = 0; i < 2; i++)
		{
			string json = HostUrlDecode(GetVideoJson(videoId, i == 1));

			if (!json.empty())
			{
				JsonReader Reader;
				JsonValue Root;

				if (Reader.parse(json, Root) && Root.isObject())
				{
					JsonValue streamingData = Root["streamingData"];

					if (streamingData.isObject()) player_response_jsonData = json;
					else if (error_message.empty())
					{
						JsonValue playabilityStatus = Root["playabilityStatus"];
						if (playabilityStatus.isObject())
						{
							JsonValue status = playabilityStatus["status"];
							if (status.isString() && status.asString() != "OK")
							{
								JsonValue reason = playabilityStatus["reason"];
								if (reason.isString()) error_message = reason.asString();
							}
						}
					}
				}
			}
			if (!player_response_jsonData.empty()) break;
		}
		if (player_response_jsonData.empty())
		{
			player_response_jsonData = GetJsonCode(WebData, MATCH_PLAYER_RESPONSE);
			player_response_jsonData.replace("\\/", "/");
			player_response_jsonData.replace("\\\"", "\"");
			player_response_jsonData.replace("\\\\", "\\");
		}
		if (player_response_jsonData.empty()) player_response_jsonData = GetJsonCode(WebData, MATCH_PLAYER_RESPONSE_2);

		player_sponsors_jsonData = HostUrlGetString("https://sponsor.ajay.app/api/skipSegments?categories=[\"sponsor\", \"selfpromo\",\"interaction\", \"intro\", \"outro\", \"preview\", \"music_offtopic\", \"filler\"]&videoID=" + videoId);
		player_sponsors_jsonData.replace("\\/", "/");
		// player_sponsors_jsonData.replace("\\\"", "\"");
		player_sponsors_jsonData.replace("\\\\", "\\");

		player_chapter_jsonData = GetJsonCode(WebData, MATCH_CHAPTER_RESPONSE);
		if (player_chapter_jsonData.empty()) player_chapter_jsonData = GetJsonCode(WebData, MATCH_CHAPTER_RESPONSE2);
		player_chapter_jsonData.replace("\\/", "/");
		// player_chapter_jsonData.replace("\\\"", "\"");
		player_chapter_jsonData.replace("\\\\", "\\");

		int stream_map_start = -1;
		int stream_map_len = 0;

		int adaptive_fmts_start = -1;
		int adaptive_fmts_len = 0;

		int hlsmpd_start = -1;
		int hlsmpd_len = 0;

		int dashmpd_start = -1;
		int dashmpd_len = 0;

		// url_encoded_fmt_stream_map
		if (stream_map_start <= 0 && (stream_map_start = WebData.find(MATCH_STREAM_MAP_START)) >= 0)
		{
			stream_map_start += MATCH_STREAM_MAP_START.size() + 2;
			stream_map_len = WebData.find(MATCH_END, stream_map_start + 10);
			if (stream_map_len > 0) stream_map_len += 10;
			else stream_map_len = WebData.size();
			stream_map_len -= stream_map_start;
		}

		// adaptive_fmts
		if (adaptive_fmts_start <= 0 && (adaptive_fmts_start = WebData.find(MATCH_ADAPTIVE_FMTS_START)) >= 0)
		{
			adaptive_fmts_start += MATCH_ADAPTIVE_FMTS_START.size() + 2;
			adaptive_fmts_len = WebData.find(MATCH_END, adaptive_fmts_start + 10);
			if (adaptive_fmts_len > 0) adaptive_fmts_len += 10;
			else adaptive_fmts_len = WebData.size();
			adaptive_fmts_len -= adaptive_fmts_start;
		}

		// dash mainfest mpd
		if (dashmpd_start <= 0 && (dashmpd_start = WebData.find(MATCH_DASHMPD_START)) >= 0)
		{
			dashmpd_start += MATCH_DASHMPD_START.size() + 2;
			dashmpd_len = WebData.find(MATCH_END, dashmpd_start + 10);
			if (dashmpd_len > 0) dashmpd_len += 10;
			else dashmpd_len = WebData.size();
			dashmpd_len -= dashmpd_start;
		}


		// hls live streaming
		if (hlsmpd_start <= 0 && (hlsmpd_start = WebData.find(MATCH_HLSMPD_START)) >= 0)
		{
			hlsmpd_start += MATCH_HLSMPD_START.size() + 2;
			hlsmpd_len = WebData.find(MATCH_END, hlsmpd_start + 10);
			if (hlsmpd_len > 0) hlsmpd_len += 10;
			else hlsmpd_len = WebData.size();
			hlsmpd_len -= hlsmpd_start;
		}

		if (player_response_jsonData.empty() && stream_map_len <= 0 && hlsmpd_len <= 0) return "";

		if (@MetaData !is null)
		{
			string dat = HostUrlDecode(WebData);
			string title, thumb;

			MetaData["webUrl"] = "http://www.youtube.com/watch?v=" + videoId;
			string search1 = "<meta property=\"og:image\" content=";
			int first = WebData.find(search1);

			if (first >= 0) first += search1.size();
			else
			{
				string search2 = "<meta name=\"twitter:image\" content=";
				first = WebData.find(search2);
				if (first >= 0) first += search2.size();
			}
			if (first >= 0)
			{
				int next = WebData.find(">", first);

				if (next >= 0)
				{
					thumb = WebData.substr(first, next - first);
					thumb.Trim("\"");
				}
			}

			title = FixHtmlSymbols(GetEntry(WebData, "<title>", "</title>"));

			if (!thumb.empty()) MetaData["thumbnail"] = thumb;
			MetaData["title"] = title;

			int type3D = 0;
			string threed = GetEntry(WebData, "threed_layout", ",");
			threed.Trim();
			threed.Trim("\"");
			threed.Trim(":");
			threed.Trim("\"");
			threed.Trim();
			if (threed == "1") type3D = 1; // SBS Half
			else if (threed == "2") type3D = 2; // SBS Full
			else if (threed == "3") type3D = 3; // T&B Half
			else if (threed == "4") type3D = 4; // T&B Full
			if (type3D > 0) MetaData["type3D"] = type3D;

			if (title.find("360°") >= 0 || title.find("360VR") >= 0) MetaData["is360"] = 1;
		}

		string final_url, final_url2;
		string final_ext;
		JsonReader Reader;
		JsonValue Root;
		bool okJson = !player_response_jsonData.empty() && Reader.parse(player_response_jsonData, Root) && Root.isObject();
		if (okJson)
		{
			if (@MetaData !is null)
			{
				JsonValue playabilityStatus = Root["playabilityStatus"];
				if (playabilityStatus.isObject())
				{
					JsonValue status = playabilityStatus["status"];
					if (status.isString() && status.asString() != "OK")
					{
						if (error_message.empty())
						{
							JsonValue reason = playabilityStatus["reason"];
							if (reason.isString()) MetaData["errorMessage"] = reason.asString();
						}
						else MetaData["errorMessage"] = error_message;
					}
				}
			}
		}

		bool isDash = adaptive_fmts_start <= 0 && (dashmpd_len > 0 && hlsmpd_len > 0); // 일단 live만 mpd 지원되게 하자...
		if (isDash || hlsmpd_len > 0)
		{
			string url;

			if (okJson)
			{
				JsonValue streamingData = Root["streamingData"];
				if (streamingData.isObject())
				{
					JsonValue streamingUrl = streamingData[isDash ? "dashManifestUrl" : "hlsManifestUrl"];
					if (streamingUrl.isString()) url = streamingUrl.asString();
				}
			}
			if (url.empty())
			{
				if (isDash) url = WebData.substr(dashmpd_start, dashmpd_len);
				else url = WebData.substr(hlsmpd_start, hlsmpd_len);
			}

			url = HostUrlDecode(HostUrlDecode(url));
			url.replace("\\/", "/");
			url = CorrectURL(url);
			if (url.find("/s/") > 0)
			{
				string tmp = url;
				string signature = HostRegExpParse(tmp, "/s/([0-9A-Z]+.[0-9A-Z]+)");

				if (!signature.empty()) url = SignatureDecode(tmp, signature, "/signature/", WebData, js_data, JSFuncs, JSFuncArgs);
			}
			url = url + "?ForceBHD";
			final_url = url;
			final_ext = "mp4";

			//if (@MetaData !is null) MetaData["chatUrl"] = "https://www.youtube.com/live_chat?v=" + videoId + "&is_popout=1";
		}
		else
		{
			int final_itag = 0;
			bool IsOK = false;

			if (okJson)
			{		
				JsonValue streamingData = Root["streamingData"];
				if (streamingData.isObject())
				{
					for (int i = 0; i < 2; i++)
					{
						JsonValue formats = streamingData[i == 0 ? "formats" : "adaptiveFormats"];
						if (formats.isArray())
						{
							for(int j = 0, len = formats.size(); j < len; j++)
							{
								JsonValue format = formats[j];

								if (format.isObject())
								{
									if (i == 1)
									{
										JsonValue type = format["type"];

										// fragmented url
										if (type.isString() && type.asString() == "FORMAT_STREAM_TYPE_OTF") continue;
									}

									QualityListItem item;
									JsonValue itag = format["itag"];
									JsonValue url = format["url"];
									JsonValue bitrate = format["bitrate"];
									JsonValue width = format["width"];
									JsonValue height = format["height"];
									JsonValue quality = format["quality"];
									JsonValue qualityLabel = format["qualityLabel"];
									JsonValue projectionType = format["projectionType"];
									JsonValue mimeType = format["mimeType"];
									JsonValue fps = format["fps"];
									JsonValue cipher = format["cipher"];
									JsonValue signatureCipher = format["signatureCipher"];
									JsonValue audioTrack = format["audioTrack"];
									
									if (itag.isInt()) item.itag = itag.asInt();
									if (width.isInt() && height.isInt()) item.resolution = formatInt(width.asInt()) + "x" + formatInt(height.asInt());
									if (bitrate.isInt())
									{
										item.bitrate = GetBitrateString(bitrate.asInt());
										item.bitrateVal = bitrate.asInt();
									}
									if (quality.isString()) item.quality = quality.asString();
									if (qualityLabel.isString()) item.qualityDetail = qualityLabel.asString();
									if (mimeType.isString()) item.format = GetCodecName(HostUrlDecode(mimeType.asString()));
									if (fps.isDouble())
									{
										double val = fps.asDouble();

										if (val > 0) item.fps = val;
									}
									if (projectionType.isString())
									{
										int type = parseInt(quality.asString());

										if (type == 2)
										{
											MetaData["type3D"] = 0;
											MetaData["is360"] = 1; // 360 VR
										}
										else if (type == 3)
										{
											MetaData["type3D"] = 3; 	// T&B Half
											MetaData["is360"] = 1; // 360 VR
										}
										else if (type == 4)
										{
										}
										int type3D;
										if (MetaData.get("type3D", type3D)) item.type3D = type3D;

										int is360;
										if (MetaData.get("is360", is360)) item.is360 = is360 == 1;
									}
									if (audioTrack.isObject())
									{
										JsonValue displayName = audioTrack["displayName"];
										if (displayName.isString()) item.audioName = displayName.asString();

										JsonValue id = audioTrack["id"];
										if (id.isString())
										{
											item.audioCode = id.asString();
											int p = item.audioCode.find(".");
											if (p > 0) item.audioCode = item.audioCode.Left(p);
										}
									}
									if (url.isString())
									{
										item.url = url.asString();
										if (item.url.find("xtags=drc") > 0) continue;
									}
									else if (cipher.isString() || signatureCipher.isString())
									{
										string u, signature, sigName = "signature";
										string str = cipher.isString() ? cipher.asString() : signatureCipher.isString() ? signatureCipher.asString() : "";

										str.replace("\\u0026", "&");
										array<string> params = str.split("&");
										for (int i = 0, len = params.size(); i < len; i++)
										{
											string param = params[i];
											int k = param.find("=");

											if (k > 0)
											{
												string paramHeader = param.Left(k);
												string paramValue = param.substr(k + 1);

												if (paramHeader == "url") u = HostUrlDecode(paramValue);
												else if (paramHeader == "s") signature = HostUrlDecode(paramValue);
												else if (paramHeader == "sp") sigName = paramValue;
												else if (!u.empty()) u = u + "&" + paramHeader + "=" + HostUrlDecode(paramValue);
											}
											else if (!u.empty()) u = u + "&" + param;
										}
										if (!u.empty() && !signature.empty() && !js_data.empty())
										{
											string param = "&" + sigName + "=";

											u = SignatureDecode(u, signature, param, WebData, js_data, JSFuncs, JSFuncArgs);
										}
										item.url = u;
									}
									item.url.replace("\\u0026", "&");

									if (item.itag != 0 && !item.url.empty())
									{
										if (videoId == "jj9RZODDDZs" && item.url.find("clen=") < 0) continue; // 특수한 경우 ㄷㄷㄷ
										if (item.url.find("dur=0.000") > 0) continue;

										if (item.url.find("xtags=vproj=mesh") > 0) MetaData["is360"] = 1;
										item.isHDR = IsHDR(item.itag);
										if (@QualityList !is null) AppendQualityList(QualityList, item, "");
										if (SelectBestProfile(final_itag, final_ext, item.itag, youtubeSets)) final_url = item.url;
										if (SelectBestProfile2(final_itag, final_ext, item.itag, youtubeSets)) final_url2 = item.url;
										IsOK = true;
									}
								}
							}
						}
					}
				}
			}

			if (!IsOK)
			{
				string str;
				if (stream_map_len > 0) str = WebData.substr(stream_map_start, stream_map_len);
				if (adaptive_fmts_len > 0)
				{
					if (!str.empty()) str = str + ",";
					str += WebData.substr(adaptive_fmts_start, adaptive_fmts_len);
				}
				str.replace("\\u0026", "&");

				array<string> lines = str.split(",");
				for (int i = 0, len = lines.size(); i < len; i++)
				{
					string line = lines[i];

					line.Trim(":");
					line.Trim("\"");
					line.Trim("\'");
					line.Trim(",");

					int itag = 0;
					string url, signature, sig, sigName = "signature";
					QualityListItem item;

					array<string> params = line.split("&");
					for (int j = 0, len = params.size(); j < len; j++)
					{
						string param = params[j];
						int k = param.find("=");

						if (k > 0)
						{
							string paramHeader = param.Left(k);
							string paramValue = param.substr(k + 1);

							// "quality", "fallback_host", "url", "itag", "type"
							if (paramHeader == "url")
							{
								url = HostUrlDecode(HostUrlDecode(paramValue));
								url.replace("http://", "https://");
							}
							else if (paramHeader == "itag")
							{
								itag = parseInt(paramValue);
								item.itag = itag;
							}
							else if (paramHeader == "sig")
							{
								sig = HostUrlDecode(HostUrlDecode(paramValue));
								sig.Trim();
								signature = "";
							}
							else if (paramHeader == "s")
							{
								signature = HostUrlDecode(HostUrlDecode(paramValue));
								signature.Trim();
								sig = "";
							}
							else if (paramHeader == "sp")
							{
								sigName = HostUrlDecode(paramValue);
								sigName.Trim();
							}
							else if (paramHeader == "quality")
							{
								item.quality = paramValue;
							}
							else if (paramHeader == "size")
							{
								item.resolution = paramValue;
							}
							else if (paramHeader == "bitrate")
							{
								int64 bit = parseInt(paramValue);

								item.bitrate = GetBitrateString(bit);
								item.bitrateVal = bit;
							}
							else if (paramHeader == "projection_type")
							{
								int type = parseInt(paramValue);

								if (type == 2)
								{
									MetaData["type3D"] = 0;
									MetaData["is360"] = 1; // 360 VR
								}
								else if (type == 3)
								{
									MetaData["type3D"] = 3; 	// T&B Half
									MetaData["is360"] = 1; // 360 VR
								}
								else if (type == 4)
								{
								}
								int type3D;
								if (MetaData.get("type3D", type3D)) item.type3D = type3D;

								int is360;
								if (MetaData.get("is360", is360)) item.is360 = is360 == 1;
							}
							else if (paramHeader == "type")
							{
								item.format = GetCodecName(HostUrlDecode(paramValue));
							}
							else if (paramHeader == "fps")
							{
								double fps = parseFloat(paramValue);

								if (fps > 0) item.fps = fps;
							}
						}
					}
					if (videoId == "jj9RZODDDZs" && url.find("clen=") < 0) continue; // 특수한 경우 ㄷㄷㄷ
					if (url.find("dur=0.000") > 0) continue;

					if (!sig.empty()) url = url + "&signature=" + sig;
					else if (!signature.empty() && !js_data.empty())
					{
						string param = "&" + sigName + "=";

						url = SignatureDecode(url, signature, param, WebData, js_data, JSFuncs, JSFuncArgs);
					}
					if (itag > 0)
					{
						if (url.find("xtags=vproj=mesh") > 0) MetaData["is360"] = 1;
						item.isHDR = IsHDR(item.itag);
						if (@QualityList !is null) AppendQualityList(QualityList, item, url);
						if (SelectBestProfile(final_itag, final_ext, itag, youtubeSets)) final_url = url;
						if (SelectBestProfile2(final_itag, final_ext, itag, youtubeSets)) final_url2 = url;
					}
				}
			}
		}

		if (final_url.empty()) final_url = final_url2;
		if (!final_url.empty())
		{
			final_url.replace("http://", "https://");
			if (!videoId.empty() && (@MetaData !is null))
			{
				bool ParseMeta = false;
				array<dictionary> subtitle;
				JsonReader Reader;
				JsonValue Root;

				if (!player_response_jsonData.empty() && Reader.parse(player_response_jsonData, Root) && Root.isObject())
				{
					JsonValue videoDetails = Root["videoDetails"];
					if (videoDetails.isObject())
					{
						JsonValue title = videoDetails["title"];
						if (title.isString())
						{
							string sTitle = title.asString();

							if (!sTitle.empty())
							{
								sTitle = FixHtmlSymbols(sTitle);
								sTitle.replace("+", " ");
								MetaData["title"] = sTitle;
								ParseMeta = true;
							}
						}

						JsonValue author = videoDetails["author"];
						if (author.isString())
						{
							string sAuthor = author.asString();

							if (!sAuthor.empty())
							{
								sAuthor.replace("+", " ");
								MetaData["author"] = sAuthor;
								ParseMeta = true;
							}
						}

						JsonValue shortDescription = videoDetails["shortDescription"];
						if (shortDescription.isString())
						{
							string sDesc = shortDescription.asString();

							if (!sDesc.empty())
							{
								sDesc = FixHtmlSymbols(sDesc);
								sDesc.replace("+", " ");
								sDesc.replace("\\r\\n", "\n");
								sDesc.replace("\\n", "\n");
								MetaData["content"] = sDesc;
								ParseMeta = true;
							}
						}

						JsonValue lengthSeconds = videoDetails["lengthSeconds"];
						if (lengthSeconds.isString()) MetaData["duration"] = parseInt(lengthSeconds.asString()) * 1000;

						JsonValue viewCount = videoDetails["viewCount"];
						if (viewCount.isString()) MetaData["viewCount"] = viewCount.asString();

						JsonValue thumbnail = videoDetails["thumbnail"];
						if (thumbnail.isObject())
						{
							JsonValue thumbnails = thumbnail["thumbnails"];
							if (thumbnails.isArray())
							{
								for (int j = 0, len = thumbnails.size(); j < len; j++)
								{
									JsonValue it = thumbnails[j];
									
									if (it.isObject())
									{
										JsonValue url = it["url"];

										if (url.isString())
										{
											MetaData["thumbnail"] = url.asString();
											break;
										}
									}
								}
							}
						}
					}

					JsonValue microformat = Root["microformat"];
					if (!microformat.isObject())
					{
						string temp = GetJsonCode(WebData, MATCH_PLAYER_RESPONSE_2);

						if (!temp.empty() && Reader.parse(temp, Root) && Root.isObject())
						{
							microformat = Root["microformat"];
						}
					}
					if (microformat.isObject())
					{
						JsonValue playerMicroformatRenderer = microformat["playerMicroformatRenderer"];
						if (playerMicroformatRenderer.isObject())
						{
							JsonValue publishDate = playerMicroformatRenderer["publishDate"];
							if (publishDate.isString())
							{
								string sDate = publishDate.asString();

								if (!sDate.empty())
								{
									MetaData["date"] = sDate.substr(0, 10);
									ParseMeta = true;
								}
							}
						}
						

						JsonValue viewCount = playerMicroformatRenderer["viewCount"];
						if (viewCount.isString()) MetaData["viewCount"] = viewCount.asString();

						JsonValue lengthSeconds = playerMicroformatRenderer["lengthSeconds"];
						if (lengthSeconds.isString()) MetaData["duration"] = parseInt(lengthSeconds.asString()) * 1000;						
					}

					JsonValue captions = Root["captions"];
					if (captions.isObject())
					{
						JsonValue playerCaptionsTracklistRenderer = captions["playerCaptionsTracklistRenderer"];

						if (playerCaptionsTracklistRenderer.isObject())
						{
							JsonValue captionTracks = playerCaptionsTracklistRenderer["captionTracks"];

							if (captionTracks.isArray())
							{
								for (int j = 0, len = captionTracks.size(); j < len; j++)
								{
									JsonValue captionTrack = captionTracks[j];

									if (captionTrack.isObject())
									{
										JsonValue baseUrl = captionTrack["baseUrl"];
										if (baseUrl.isString())
										{
											string vtt = "&fmt=vtt";
											string url = baseUrl.asString();
											int p = url.find("&fmt=");
											if (p > 0)
											{
												int e = url.find("&", p + 1);
												if (e < 0) e = url.length();
												url.erase(p, e - p);
												url.insert(p, vtt);
											}
											else url += vtt;

											string subname;
											JsonValue name = captionTrack["name"];
											if (name.isObject())
											{
												JsonValue simpleText = name["simpleText"];
												if (simpleText.isString()) subname = simpleText.asString();
											}
											else
											{
												JsonValue runs = name["runs"];

												if (runs.isArray())
												{
													for (int k = 0, len = runs.size(); k < len; k++)
													{
														JsonValue run = runs[k];
														if (run.isObject())
														{
															JsonValue text = run["text"];
															if (text.isString())
															{
																subname = text.asString();
																break;
															}
														}
													}
												}
											}
											if (subname.rfind(" - Default") == subname.length() - 10) subname = subname.substr(0, subname.length() - 10);

											JsonValue languageCode = captionTrack["languageCode"];

											dictionary item;

											JsonValue kind = captionTrack["kind"];
											if (kind.isString()) item["kind"] = kind.asString();

											item["name"] = subname;
											item["url"] = url;
											if (languageCode.isString()) item["langCode"] = languageCode.asString();
											subtitle.insertLast(item);
										}
									}
								}
							}
						}
					}
				}

				if (!ParseMeta)
				{
					string api = "https://www.googleapis.com/youtube/v3/videos?id=" + videoId + "&part=snippet,statistics,contentDetails&fields=items/snippet/title,items/snippet/publishedAt,items/snippet/channelTitle,items/snippet/description,items/statistics,items/contentDetails/duration";
					string json = HostUrlGetStringWithAPI(api, GetUserAgent());
					JsonReader Reader;
					JsonValue Root;

					if (Reader.parse(json, Root) && Root.isObject())
					{
						JsonValue items = Root["items"];
						if (items.isArray())
						{
							JsonValue item = items[0];

							if (item.isObject())
							{
								JsonValue statistics = item["statistics"];
								if (statistics.isObject())
								{
									JsonValue viewCount = statistics["viewCount"];
									if (viewCount.isString()) MetaData["viewCount"] = viewCount.asString();

									JsonValue likeCount = statistics["likeCount"];
									if (likeCount.isString()) MetaData["likeCount"] = likeCount.asString();

									JsonValue dislikeCount = statistics["dislikeCount"];
									if (dislikeCount.isString()) MetaData["dislikeCount"] = dislikeCount.asString();
								}

								JsonValue snippet = item["snippet"];
								if (snippet.isObject())
								{
									JsonValue title = snippet["title"];
									if (title.isString())
									{
										string sTitle = title.asString();

										if (!sTitle.empty()) MetaData["title"] = FixHtmlSymbols(sTitle);
									}

									JsonValue channelTitle = snippet["channelTitle"];
									if (channelTitle.isString())
									{
										string sAuthor = channelTitle.asString();

										if (!sAuthor.empty()) MetaData["author"] = sAuthor;
									}

									JsonValue description = snippet["description"];
									if (description.isString())
									{
										string sDesc = description.asString();

										if (!sDesc.empty())
										{
											sDesc = FixHtmlSymbols(sDesc);
											sDesc.replace("\\r\\n", "\n");
											sDesc.replace("\\n", "\n");
											MetaData["content"] = sDesc;
										}
									}

									JsonValue publishedAt = snippet["publishedAt"];
									if (publishedAt.isString())
									{
										string sDate = publishedAt.asString();

										if (!sDate.empty()) MetaData["date"] = sDate.substr(0, 10);
									}
								}

								JsonValue contentDetails = item["contentDetails"];
								if (contentDetails.isObject())
								{
									JsonValue duration = contentDetails["duration"];
									if (duration.isString())
									{
										array<dictionary> match;

										if (HostRegExpParse(duration.asString(), "PT(\\d+H)?(\\d{1,2}M)?(\\d{1,2}S)?", match) && match.size() == 4)
										{
											string h;
											string m;
											string s;

											match[1].get("first", h);
											match[2].get("first", m);
											match[3].get("first", s);

											MetaData["duration"] = (parseInt(h) * 3600 + parseInt(m) * 60 + parseInt(s)) * 1000;
										}
									}
								}
							}
						}
					}
				}

				if (subtitle.empty() && (@QualityList !is null))
				{
					// langCode: http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
					// http://video.google.com/timedtext?lang=en&v=R9Fu6Leb_aE&fmt=vtt
					// &fmt=srt		&fmt=vtt
					string api = "http://www.youtube.com/api/timedtext?v=" + videoId + "&expire=1&type=list";
					string xml = HostUrlGetString(api, GetUserAgent());
					XMLDocument dxml;

					if (dxml.Parse(xml))
					{
						XMLElement Root = dxml.RootElement();

						if (Root.isValid() && Root.Name() == "transcript_list")
						{
							XMLElement track = Root.FirstChildElement("track");

							while (track.isValid())
							{
								XMLAttribute lang_code = track.FindAttribute("lang_code");

								if (lang_code.isValid())
								{
									XMLAttribute name = track.FindAttribute("name");
									XMLAttribute lang_translated = track.FindAttribute("lang_translated");
									XMLAttribute lang_original = track.FindAttribute("lang_original");
									string s1 = name.isValid() ? name.Value() : "";
									string s2 = lang_translated.isValid() ? lang_translated.Value() : "";
									string s3 = lang_original.isValid() ? lang_original.Value() : "";
									string s4 = lang_code.isValid() ? lang_code.Value() : "";
									string s5 = "http://www.youtube.com/api/timedtext?v=" + videoId + "&lang=" + s4;
									dictionary item;

									item["name"] = s1;
									item["langTranslated"] = s2;
									item["langOriginal"] = s3;
									item["langCode"] = s4;
									item["url"] = s5;
									subtitle.insertLast(item);
								}
								track = track.NextSiblingElement();
							}
						}
					}
				}
				if (!subtitle.empty() && (@QualityList !is null)) MetaData["subtitle"] = subtitle;

				// Chapters
				if ((@QualityList !is null) && (!player_sponsors_jsonData.empty() || !player_chapter_jsonData.empty()))
				{
					JsonReader reader;
					JsonValue sponsorsRoot;
					JsonValue ytRoot;

					array<dictionary> ytChapt;
					array<dictionary> spChapt;

					// Youtube Chapters
					if (reader.parse(player_chapter_jsonData, ytRoot) && ytRoot.isObject())
					{
						JsonValue chapters = ytRoot["chapters"];

						if (chapters.isArray())
						{
							for(int j = 0, len = chapters.size(); j < len; j++)
							{
								JsonValue chapter = chapters[j];

								if (chapter.isObject())
								{
									JsonValue chapterRenderer = chapter["chapterRenderer"];

									if (chapterRenderer.isObject())
									{
										JsonValue title = chapterRenderer["title"];

										if (title.isObject())
										{
											JsonValue simpleText = title["simpleText"];
											JsonValue timeRangeStartMillis = chapterRenderer["timeRangeStartMillis"];

											if (simpleText.isString() && timeRangeStartMillis.isInt())
											{
												dictionary item;

												item["title"] = simpleText.asString();
												item["time"] = timeRangeStartMillis.asInt();
												ytChapt.insertLast(item);
											}
										}
									}
								}
							}
						}
					}

					// Sponsors
					if (reader.parse(player_sponsors_jsonData, sponsorsRoot) && sponsorsRoot.isArray())
					{


						// Apparently declaring string dictionaries is not a thing??
						dictionary typesToId = {
							{"sponsor", 0},
							{"selfpromo", 1},
							{"interaction", 2},
							{"intro", 3},
							{"outro", 4},
							{"preview", 5},
							{"music_offtopic", 6},
							{"filler", 7}
						};

						array<string> readableCats = {"Sponsor", "Self Promotion", "Interaction Reminder", "Intro", "Outro", "Preview", "No Music", "Non-essential Filler"};

						for(int j = 0, len = sponsorsRoot.size(); j < len; j++)
						{
							JsonValue chapter = sponsorsRoot[j];

							if (chapter.isObject())
							{
								JsonValue segment = chapter["segment"];
								if (segment.isArray()) {
									dictionary startItem;
									dictionary endItem;

									startItem["time"] = segment[0].asFloat() * 1000;
									endItem["time"] = segment[1].asFloat() * 1000;

									string startChapterName = getChapterName(ytChapt, int(startItem["time"]));
									string endChapterName = getChapterName(ytChapt, int(endItem["time"]));

									int categoryId = int(typesToId[chapter["category"].asString()]);
									startItem["title"] = (startChapterName != "" ? startChapterName + " | " : "") + "SB - " + readableCats[categoryId];

									endItem["title"] = endChapterName == "" ? "Video" : endChapterName;

									spChapt.insertLast(startItem);
									spChapt.insertLast(endItem);
								}
							}
						}
					}

					array<dictionary> chapt;

					for (int i = 0; i < ytChapt.length(); i++) {
						string sponsor = getChapterName(spChapt, int(ytChapt[i]["time"]));
						if (sponsor.findFirst("SB -") > 0) {
							ytChapt[i]["title"] = string(ytChapt[i]["title"]) + " | " + sponsor;
						}
						ytChapt[i]["time"] = formatFloat(float(ytChapt[i]["time"]), "", 32, 0);
						chapt.insertLast(ytChapt[i]);
					}
					for (int i = 0; i < spChapt.length(); i++) {
						spChapt[i]["time"] = formatFloat(float(spChapt[i]["time"]), "", 32, 0);
						chapt.insertLast(spChapt[i]);
					}

					if (!chapt.empty() && (@QualityList !is null)) MetaData["chapter"] = chapt;

				}
			}

			if (@MetaData !is null) MetaData["fileExt"] = final_ext;
			return final_url;
		}
	}
	return "";
}

string getChapterName(array<dictionary> chapters, int time) {
	string name = "";
	for (int i = 0; i < chapters.length(); i++) {
		if (int(chapters[i]["time"]) <= time && (i >= chapters.length() - 1 ? true : int(chapters[i+1]["time"]) > time)) {
			name = string(chapters[i]["title"]);
			break;
		}
	}
	return name;
}

bool PlaylistCheck(const string &in path)
{
	string url = path;

	url.MakeLower();
	url = RepleaceYouTubeUrl(url);
	url.replace("https", "");
	url.replace("http", "");

	if (url == YOUTUBE_MP_URL) return false;
	if (url.find(YOUTUBE_PL_URL) >= 0 || (url.find(YOUTUBE_URL) >= 0 && url.find("&list=") >= 0)) return true;
	if (url.find(YOUTUBE_USER_URL) >= 0 || url.find(YOUTUBE_CHANNEL_URL) >= 0 || url.find(YOUTUBE_USER_SHORT_URL) >= 0) return true;
	if (url.find(YOUTUBE_URL_LIBRARY) >= 0) return true;
	if (url.find(YOUTUBE_MP_URL) >= 0 && url.find("watch?") < 0)
	{
		int p = url.find(YOUTUBE_MP_URL);

		url.erase(p, YOUTUBE_MP_URL.size());
		if (url.find("/") >= 0 || url.find("?list=") >= 0 || url.find("&") >= 0) return true;
	}

	return false;
}

array<dictionary> PlayerYouTubePlaylistByAPI(string url)
{
	array<dictionary> ret;
	string pid = HostRegExpParse(url, "list=([-a-zA-Z0-9_]+)");

	if (!pid.empty())
	{
		string nextToken;
		string vid = GetVideoID(url);
		string maxResults = HostRegExpParse(url, "maxResults=([0-9]+)");
		int maxCount = parseInt(maxResults);

		for (int i = 0; i < 200; i++)
		{
			string api = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=" + pid + "&maxResults=50";

			if (!nextToken.empty())
			{
				api = api + "&pageToken=" + nextToken;
				nextToken = "";
			}
			string json = HostUrlGetStringWithAPI(api, GetUserAgent());
			HostIncTimeOut(5000);
			if (json.empty()) break;
			else
			{
				JsonReader Reader;
				JsonValue Root;

				if (Reader.parse(json, Root) && Root.isObject())
				{
					JsonValue nextPageToken = Root["nextPageToken"];
					if (nextPageToken.isString()) nextToken = nextPageToken.asString();

					JsonValue items = Root["items"];
					if (items.isArray())
					{
						for(int j = 0, len = items.size(); j < len; j++)
						{
							JsonValue item = items[j];

							if (item.isObject())
							{
								JsonValue snippet = item["snippet"];

								if (snippet.isObject())
								{
									JsonValue resourceId = snippet["resourceId"];

									if (resourceId.isObject())
									{
										JsonValue videoId = resourceId["videoId"];

										if (videoId.isString())
										{
											dictionary item;
											bool IsDel = false;

											item["url"] = "http://www.youtube.com/watch?v=" + videoId.asString();

											JsonValue title = snippet["title"];
											if (title.isString())
											{
												string str = title.asString();

												item["title"] = str;
												IsDel = "Deleted video" == str;
											}

											JsonValue thumbnails = snippet["thumbnails"];
											if (thumbnails.isObject())
											{
												JsonValue medium = thumbnails["medium"];
												string thumbnail;

												if (medium.isObject())
												{
													JsonValue url = medium["url"];

													if (url.isString()) thumbnail = url.asString();
												}
												if (thumbnail.empty())
												{
													JsonValue def = thumbnails["default"];

													if (def.isObject())
													{
														JsonValue url = def["url"];

														if (url.isString()) thumbnail = url.asString();
													}
												}
												/*
												JsonValue high = thumbnails["high"];
												if (high.isObject())
												{
													JsonValue url = high["url"];

													if (url.isString()) thumbnail = url.asString();
												}*/
												if (!thumbnail.empty()) item["thumbnail"] = thumbnail;
											}
											else if (IsDel) continue;
											if (vid == videoId.asString()) item["current"] = "1";

											ret.insertLast(item);
										}
									}
								}
							}
						}
					}
				}
			}
			if (nextToken.empty()) break;
			if (maxCount > 0 && ret.size() >= maxCount) break;
		}
	}

	return ret;
}

string FixHtmlSymbols(string inStr)
{
	inStr.replace("&quot;", "\"");
	inStr.replace("&amp;", "&");
	inStr.replace("&#39;", "'");
	inStr.replace("&#039;", "'");
	inStr.replace("\\n", "\r\n");
	inStr.replace("\n", "\r\n");
	inStr.replace("\\", "");

	inStr.replace(" - YouTube", "");
	inStr.replace(" on Vimeo", "");

	return inStr;
}

bool IsArrayExist(array<dictionary> &pls, string url)
{
	for (int i = 0; i < pls.size(); i++)
	{
		string str;
		bool isValid = pls[i].get("url", str);

		if (isValid && str == url) return true;
	}

	return false;
}

string ParserPlaylistItem(string html, int start, int len, string vid, array<dictionary> &pls)
{
	string block = html.substr(start, len);
	string szEnd = block;
	array<dictionary> match;
	string data_video_id;
	string data_video_username;
	string data_video_title;
	string data_thumbnail_url;

	while (HostRegExpParse(szEnd, "([a-z-]+)=\"([^\"]+)\"", match))
	{
		if (match.size() == 3)
		{
			string propHeader;
			string propValue;

			 match[1].get("first", propHeader);
			 match[2].get("first", propValue);
			 propHeader.Trim();
			 propValue.Trim();

			// data-video-id, data-video-clip-end, data-index, data-video-username, data-video-title, data-video-clip-start.
			if (propHeader == "data-video-id") data_video_id = propValue;
			else if (propHeader == "data-video-username") data_video_username = FixHtmlSymbols(propValue);
			else if (propHeader == "data-video-title" || propHeader == "data-title") data_video_title = FixHtmlSymbols(propValue);
			else if (propHeader == "data-thumbnail-url") data_thumbnail_url = propValue;
		}

		match[0].get("second", szEnd);
	}

	if (!data_video_id.empty())
	{
		string url = "http://www.youtube.com/watch?v=" + data_video_id;
		if (IsArrayExist(pls, url)) return "";

		dictionary item;
		item["url"] = url;
		item["title"] = data_video_title;
		if (data_thumbnail_url.empty())
		{
			int p = html.find("yt-thumb-clip", start);

			if (p >= 0)
			{
				int img = html.find(data_video_id, p);

				if (img > p)
				{
					while (img > p)
					{
						string ch = html.substr(img, 1);

						if (ch == "\"" || ch == "=") break;
						else img--;
					}

					int end = html.find(".jpg", img);
					if (end > img)
					{
						string thumb = html.substr(img, end + 4 - img);

						thumb.Trim();
						thumb.Trim("\"");
						thumb.Trim("=");
						if (thumb.find("://") < 0)
						{
							if (thumb.find("//") == 0) thumb = "http:" + thumb;
							else thumb = "http://" + thumb;
						}
						data_thumbnail_url = thumb;
					}
				}
			}
		}
		if (!data_thumbnail_url.empty()) item["thumbnail"] = data_thumbnail_url;

		if (block.find("currently-playing") >= 0 || vid == data_video_id) item["current"] = "1";
		pls.insertLast(item);
	}

	return data_video_id;
}

string ParserPlaylistItem(JsonValue object, array<dictionary> &pls, string vid)
{
	JsonValue videoId = object["videoId"];
	string lastvideoId;

	if (videoId.isString())
	{
		string url = "https://www.youtube.com/watch?v=" + videoId.asString();
		if (IsArrayExist(pls, url)) return lastvideoId;

		JsonValue title = object["title"];
		if (title.isObject())
		{
			JsonValue simpleText = title["simpleText"];

			if (!simpleText.isString())
			{
				JsonValue runs = title["runs"];

				if (runs.isObject())
				{
					JsonValue zero = runs["0"];

					if (zero.isObject()) simpleText = zero["text"];
				}
				else if (runs.isArray())
				{
					JsonValue zero = runs[0];

					if (zero.isObject()) simpleText = zero["text"];
				}
			}
			if (simpleText.isString())
			{
				string duration;
				JsonValue lengthSeconds = object["lengthSeconds"];
				JsonValue lengthText = object["lengthText"];

				if (lengthSeconds.isUInt()) duration = lengthSeconds.asString();
				else if (lengthText.isObject())
				{
					JsonValue simpleText = lengthText["simpleText"];

					if (simpleText.isString()) duration = simpleText.asString();
				}

				string thumb;
				JsonValue thumbnail = object["thumbnail"];
				if (thumbnail.isObject())
				{
					JsonValue thumbnails = thumbnail["thumbnails"];

					if (thumbnails.isArray())
					{
						JsonValue th = thumbnails[0];

						if (th.isObject())
						{
							JsonValue url = th["url"];

							if (url.isString()) thumb = url.asString();
						}
					}
				}

				lastvideoId = videoId.asString();

				dictionary item;
				item["url"] = url;
				item["title"] = simpleText.asString();
				item["duration"] = duration;
				if (!thumb.empty()) item["thumbnail"] = thumb;
				if (lastvideoId == vid) item["current"] = "1";
				pls.insertLast(item);
			}
		}
	}
	return lastvideoId;
}

JsonValue GetJsonPath(JsonValue object, string path)
{
	JsonValue ret;

	while (!path.empty())
	{
		int p = path.find("/");
		string str;

		if (p >= 0)
		{
			str = path.substr(0, p);
			path.erase(0, p + 1);
		}
		else
		{
			str = path;
			path = "";
		}
		if (!str.empty())
		{
			JsonValue r;

			if (object.isObject()) r = object[str];
			else if (object.isArray()) r = object[parseInt(str)];
			if (path.empty()) ret = r;
			if (r.isObject() || r.isArray()) object = r;
			else break;
		}
	}
	return ret;
}


string MATCH_PLAYLIST_ITEM_START	= "<li class=\"yt-uix-scroller-scroll-unit ";
string MATCH_PLAYLIST_ITEM_START2	= "<tr class=\"pl-video yt-uix-tile ";
string MATCH_PLAYLIST_ITEM_START3	= "\"playlistVideoRenderer\"";

array<dictionary> PlaylistParse(const string &in path)
{
	array<dictionary> ret;

//HostOpenConsole();
	if (PlaylistCheck(path))
	{
		string url = path;

		string channelId = HostRegExpParse(url, "www.youtube.com/(?:channel/|c/|user/|@)([^/?&#]+)");
		if (!channelId.empty())
		{
			if (url.find(YOUTUBE_CHANNEL_URL) < 0)
			{
				string dataStr = HostUrlGetString(RepleaceYouTubeUrl(url), GetUserAgent());

				channelId = GetEntry(dataStr, "content=\"https://www.youtube.com/channel/", "\"");
				if (channelId.empty()) channelId = HostRegExpParse(dataStr, "(\\\\?\"channelId\\\\?\":\\\\?\"([-a-zA-Z0-9_]+)\\\\?)");
			}
			if (channelId.substr(0, 2) == "UC")
			{
				string playlistId = "UU" + channelId.substr(2, channelId.length() - 2);

				url = "https://www.youtube.com/playlist?list=" + playlistId;
			}
		}

		url = RepleaceYouTubeUrl(url);
		url = MakeYouTubeUrl(url);
		
		string pid = HostRegExpParse(url, "list=([-a-zA-Z0-9_]+)");
		string vid = GetVideoID(url);

		bool MixedFormat = pid.substr(0, 2) == "RD" || pid.substr(0, 2) == "UL" || pid.substr(0, 2) == "PU";
		if (MixedFormat) url = "https://www.youtube.com/watch?v=" + vid + "&list=" + pid;
		else url = "https://www.youtube.com/playlist?list=" + pid;

		string dataStr = HostUrlGetString(RepleaceYouTubeUrl(url), GetUserAgent());
		if (dataStr.empty()) return PlayerYouTubePlaylistByAPI(path);

		while (!dataStr.empty())
		{
			array<string> Entrys;

			GetEntrys(dataStr, "ytInitialData = ", "};", Entrys);
			dataStr = "";
			string lastvideoId;
			for (int i = 0; i < Entrys.size(); i++)
			{
				string jsonEntry = Entrys[i];
				JsonReader reader;
				JsonValue root;

				jsonEntry += "}";
				if (reader.parse(jsonEntry, root) && root.isObject())
				{
					JsonValue contents = GetJsonPath(root, "contents/twoColumnBrowseResultsRenderer/tabs/0/tabRenderer/content/sectionListRenderer/contents/0/itemSectionRenderer/contents/0/playlistVideoListRenderer/contents");
					if (!contents.isArray()) contents = GetJsonPath(root, "contents/twoColumnWatchNextResults/playlist/playlist/contents");

					if (contents.isArray())
					{
						for(int j = 0, len = contents.size(); j < len; j++)
						{
							JsonValue content = contents[j];

							if (content.isObject())
							{
								JsonValue playlistPanelVideoRenderer = content["playlistPanelVideoRenderer"];
								JsonValue playlistVideoRenderer = content["playlistVideoRenderer"];

								if (playlistPanelVideoRenderer.isObject()) lastvideoId = ParserPlaylistItem(playlistPanelVideoRenderer, ret, vid);
								else if (playlistVideoRenderer.isObject()) lastvideoId = ParserPlaylistItem(playlistVideoRenderer, ret, vid);
								HostIncTimeOut(5000);
							}
						}
					}
				}
			}
			if (!lastvideoId.empty())
			{
				url = "https://www.youtube.com/watch?v=" + lastvideoId + "&list=" + pid;
				dataStr = HostUrlGetString(RepleaceYouTubeUrl(url), GetUserAgent());
				HostIncTimeOut(5000);
			}
		}
		if (ret.size() > 0) return ret;

		url += "&disable_polymer=true";
		dataStr = HostUrlGetString(RepleaceYouTubeUrl(url), GetUserAgent());

		bool UseJson = false;
		string moreStr = MixedFormat ? "" : dataStr;
		while (!dataStr.empty())
		{
			string match;

			int p = dataStr.find(MATCH_PLAYLIST_ITEM_START);
			if (p >= 0) match = MATCH_PLAYLIST_ITEM_START;
			else
			{
				p = dataStr.find(MATCH_PLAYLIST_ITEM_START2);
				if (p >= 0) match = MATCH_PLAYLIST_ITEM_START2;
				else
				{
					p = dataStr.find(MATCH_PLAYLIST_ITEM_START3);
					if (p >= 0)
					{
						match = MATCH_PLAYLIST_ITEM_START3;
						UseJson = true;
					}
				}
			}
			if (p < 0) break;

			HostIncTimeOut(5000);
			string lastvideoId;
			while (p >= 0)
			{
				if (UseJson)
				{
					string code = GetJsonCode(dataStr, match, p);
					JsonReader reader;
					JsonValue root;

					if (reader.parse(code, root) && root.isObject())
					{
						JsonValue videoId = root["videoId"];

						if (videoId.isString())
						{
							string id = videoId.asString();
							string url = "http://www.youtube.com/watch?v=" + id;

							if (!IsArrayExist(ret, url))
							{
								dictionary item;
								item["url"] = url;

								JsonValue lengthSeconds = root["lengthSeconds"];
								if (lengthSeconds.isString()) item["duration"] = lengthSeconds.asString();

								JsonValue title = root["title"];
								if (title.isObject())
								{
									JsonValue simpleText = title["simpleText"];
									if (simpleText.isString()) item["title"] = simpleText.asString();
								}

								JsonValue thumbnail = root["thumbnail"];
								if (thumbnail.isObject())
								{
									JsonValue thumbnails = thumbnail["thumbnails"];
									if (thumbnails.isArray())
									{
										JsonValue th = thumbnails[0];

										if (th.isObject())
										{
											JsonValue url = th["url"];

											if (url.isString()) item["thumbnail"] = url.asString();
										}
									}
								}

								ret.insertLast(item);
							}
							lastvideoId = id;
						}
					}
					p += match.size();
				}
				else
				{
					p += match.size();

					int end = dataStr.find(">", p);
					if (end > p)
					{
						string id = ParserPlaylistItem(dataStr, p, end - p, vid, ret);

						if (!id.empty()) lastvideoId = id;
					}
				}
				HostIncTimeOut(5000);
				p = dataStr.find(match, p);
			}

			if (MixedFormat)
			{
				if (lastvideoId.empty()) break;

				url = "https://www.youtube.com/watch?v=" + lastvideoId + "&list=" + pid + "&disable_polymer=true";
				dataStr = HostUrlGetString(RepleaceYouTubeUrl(url), GetUserAgent());
			}
			else
			{
				moreStr = "";
				dataStr = "";
				string moreUrl = HostUrlDecode(HostRegExpParse(moreStr, "data-uix-load-more-href=\"/?([^\"]+)\\\""));
				if (!moreUrl.empty())
				{
					moreUrl.replace("&amp;", "&");
					moreUrl += "&disable_polymer=true";
					url = "https://www.youtube.com/" + moreUrl;
					string json = HostUrlGetString(url, GetUserAgent(), "x-youtube-client-name: 1\r\nx-youtube-client-version: 1.20200609.04.02\r\n");
					JsonReader Reader;
					JsonValue Root;
					if (!json.empty() && Reader.parse(json, Root) && Root.isObject())
					{
						JsonValue content_html = Root["content_html"];
						JsonValue load_more_widget_html = Root["load_more_widget_html"];

						if (content_html.isString() && load_more_widget_html.isString())
						{
							dataStr = content_html.asString();
							moreStr = load_more_widget_html.asString();
						}
					}
				}
			}
		}
		if (ret.size() > 0) return ret;

		ret = PlayerYouTubePlaylistByAPI(path);
	}

	return ret;
}
