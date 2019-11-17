using Abp.Configuration.Startup;
using Abp.Localization.Dictionaries;
using Abp.Localization.Dictionaries.Xml;
using Abp.Reflection.Extensions;

namespace Piggyvault.Localization
{
    public static class PiggyvaultLocalizationConfigurer
    {
        public static void Configure(ILocalizationConfiguration localizationConfiguration)
        {
            localizationConfiguration.Sources.Add(
                new DictionaryBasedLocalizationSource(PiggyvaultConsts.LocalizationSourceName,
                    new XmlEmbeddedFileLocalizationDictionaryProvider(
                        typeof(PiggyvaultLocalizationConfigurer).GetAssembly(),
                        "Piggyvault.Localization.SourceFiles"
                    )
                )
            );
        }
    }
}
