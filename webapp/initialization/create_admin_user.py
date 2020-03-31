from django.contrib.auth.models import User

admin_email = 'admin@admin.com'
admin_username = 'admin'

# Check if admin user exists
if len(User.objects.filter(email=admin_email)) == 0:
    # Create admin user
    User.objects.create_superuser(admin_username, admin_email, 'admin')
