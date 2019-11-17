using Abp.Authorization;
using Piggyvault.Authorization.Roles;
using Piggyvault.Authorization.Users;

namespace Piggyvault.Authorization
{
    public class PermissionChecker : PermissionChecker<Role, User>
    {
        public PermissionChecker(UserManager userManager)
            : base(userManager)
        {
        }
    }
}
