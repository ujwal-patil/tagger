
# 🏷️ Tagger

**Tagger** is a simple yet effective diff calculator for managing translation files in growing applications. It helps maintain clean, versioned, and trackable locale files (JSON/YAML), making localization workflows smoother.

---

## 📦 Installation

Add the gem to your Gemfile:

```ruby
gem 'tagger'
```

Then run:

```bash
$ bundle install
```

Or install directly via:

```bash
$ gem install tagger
```

---

## 🚀 What is Tagger?

As your application grows, so does your translation/localization data. Tagger helps **track differences (delta diffs)** in JSON/YAML locale files, manage **tagged versions**, and **automate cleanup** of outdated entries — making life easier for maintainers and translators.

---

## ⚙️ Configuration

Create an initializer file:  
`config/initializers/tagger.rb`

```ruby
Tagger.setup do |config|
  config.parent_controller = 'ApplicationController'
  config.git_branch = ENV['LOCALIZER_BRANCH'] # Optional: Branch where changes can be pushed

  # Instance for `user` locale files
  config.instance(:user) do |user_dashboard|
    user_dashboard.file_directory_path = Rails.root.join('app/assets/javascripts/dashboard-v2/locale')
    user_dashboard.file_type = :json
    user_dashboard.keep_recent_tags = 3
    user_dashboard.keep_recent_releases = 3
    user_dashboard.ignore_source_directory_files = %w()
  end

  # Instance for `reseller` locale files
  config.instance(:reseller) do |reseller_dashboard|
    reseller_dashboard.file_directory_path = Rails.root.join('app/assets/javascripts/reseller-dashboard/locale')
    reseller_dashboard.file_type = :json
    reseller_dashboard.keep_recent_tags = 3
    reseller_dashboard.keep_recent_releases = 3
    reseller_dashboard.ignore_source_directory_files = %w()
  end

  # Instance for `server` (backend) locale files
  config.instance(:server) do |server|
    server.file_directory_path = Rails.root.join('config/locales')
    server.file_type = :yml
    server.keep_recent_tags = 3
    server.keep_recent_releases = 3
    server.ignore_source_directory_files = %w(time-ago)
  end
end
```

> ✅ You can define multiple instances for different parts of your app.  
> 🧹 Unused or invalid files in the specified directory will be automatically deleted — unless explicitly ignored via `ignore_source_directory_files`.

---

## 🧑‍💻 Usage

### 1️⃣ Restart the server

Make sure to restart your Rails server after configuring.

### 2️⃣ Create a Tagger User

This user will manage translation updates via the Tagger UI:

```bash
rails tagger:create <email>
```

### 3️⃣ Access the Portal

Log in using the created email, then visit:

```
<BASE_URL>/tagger
```

You’ll be redirected to the **Tagger Web Portal**, which provides the following capabilities:

---

## 🌐 Tagger Portal Features

![Tagger Portal Screenshot](https://user-images.githubusercontent.com/28054599/184151631-665910b5-0db7-4a09-b0e1-badf115b4d60.png)

- 🔍 **View diff (delta)** between current and previous translations
- ⬇️ **Download** missing keys in the desired locale
- ✍️ **Translate** the diff file offline
- ⬆️ **Upload** translated file to merge updates
- 🏷️ **Versioning**: Only a few recent tags/releases are stored for cleanup and rollback

---

## 🧠 Best Practices

- Always translate using the **downloaded delta** to avoid duplicate or missing keys.
- Use **separate instances** for different modules (e.g., frontend, backend) for isolation.
- Set up **Git auto-push hooks** using `config.git_branch` if you want to track translation changes in a dedicated branch.
