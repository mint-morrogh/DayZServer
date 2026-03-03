/**
 * BAEZLoadingScreen - Custom loading screen for BAE-Z server
 *
 * Overrides the vanilla loading screen, login screen, login queue,
 * and login timeout backgrounds with the BAE-Z logo.
 */

modded class LoadingScreen
{
	void LoadingScreen(DayZGame game)
	{
		if (m_ImageWidgetBackground)
		{
			m_ImageWidgetBackground.LoadMaskTexture("");
			m_ImageWidgetBackground.LoadImageFile(0, "BAEZLoadingScreen/data/loadingscreen.edds", true);
			m_ImageWidgetBackground.SetImage(0);
		}
	}
};

modded class LoginScreenBase
{
	void LoginScreenBase()
	{
		Widget root = GetLayoutRoot();
		if (root)
		{
			ImageWidget bg = ImageWidget.Cast(root.FindAnyWidget("ImageBackground"));
			if (bg)
			{
				bg.LoadMaskTexture("");
				bg.LoadImageFile(0, "BAEZLoadingScreen/data/loadingscreen.edds", true);
				bg.SetImage(0);
			}
		}
	}
};

modded class LoginQueueBase
{
	void LoginQueueBase()
	{
		Widget root = GetLayoutRoot();
		if (root)
		{
			ImageWidget bg = ImageWidget.Cast(root.FindAnyWidget("ImageBackground"));
			if (bg)
			{
				bg.LoadMaskTexture("");
				bg.LoadImageFile(0, "BAEZLoadingScreen/data/loadingscreen.edds", true);
				bg.SetImage(0);
			}
		}
	}
};

modded class LoginTimeBase
{
	void LoginTimeBase()
	{
		Widget root = GetLayoutRoot();
		if (root)
		{
			ImageWidget bg = ImageWidget.Cast(root.FindAnyWidget("ImageBackground"));
			if (bg)
			{
				bg.LoadMaskTexture("");
				bg.LoadImageFile(0, "BAEZLoadingScreen/data/loadingscreen.edds", true);
				bg.SetImage(0);
			}
		}
	}
};
