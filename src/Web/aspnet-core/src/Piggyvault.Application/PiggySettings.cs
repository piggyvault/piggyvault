using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault
{
    public class OneSignalSettings
    {
        public string ApiKey { get; set; }
        public string AppId { get; set; }
    }

    public class PiggySettings
    {
        public OneSignalSettings OneSignal { get; set; }
    }
}