namespace :assets do
  namespace :precompile do
    desc "Copy necessary images"
    task :image do
      img_dir = Rails.root.join("public","assets","images")
      Dir.mkdir(img_dir) unless Dir.exist?(img_dir)

      # for treeview
      paths = []
      paths += Dir.glob(Rails.root.join("vendor", "assets",
                                       "jzaefferer-jquery-treeview-3937863",
                                       "images", "*"))
      paths.each{|p| sh "cp #{p} #{img_dir}"}
    end

    task :font do
      desc "Copy necessary fonts"
      font_dir = Rails.root.join("public","assets","fontss")
      Dir.mkdir(font_dir) unless Dir.exist?(font_dir)

      # for font awesome in twitter-bootstrap-rails
      sh "cp `bundle show twitter-bootstrap-rails`/app/assets/fonts/fontawesome-webfont.* #{font_dir}"
    end
  end
end
