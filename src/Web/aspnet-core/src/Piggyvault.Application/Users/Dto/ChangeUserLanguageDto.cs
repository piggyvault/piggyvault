using System.ComponentModel.DataAnnotations;

namespace Piggyvault.Users.Dto
{
    public class ChangeUserLanguageDto
    {
        [Required]
        public string LanguageName { get; set; }
    }
}