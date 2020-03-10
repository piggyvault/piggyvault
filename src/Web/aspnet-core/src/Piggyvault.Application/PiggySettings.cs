using Piggyvault.Piggy.Notifications;

namespace Piggyvault
{
    public class FixerSettings
    {
        public string ApiKey { get; set; }
    }

    public class OneSignalSettings
    {
        public string ApiKey { get; set; }
        public string AppId { get; set; }

        public OneSignalChannels Channels { get; set; }
    }

    public class PiggySettings
    {
        public FixerSettings Fixer { get; set; }
        public OneSignalSettings OneSignal { get; set; }
    }
}