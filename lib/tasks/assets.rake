namespace :assets do
  namespace :precompile do
    desc 'Copy necessary images'
    task :image do
      img_dir = Rails.root.join('public', 'assets', 'images')
      Dir.mkdir(img_dir) unless Dir.exist?(img_dir)

      # for treeview
      paths = []
      paths += Dir.glob(Rails.root.join('vendor', 'assets',
                                        'jzaefferer-jquery-treeview-3937863',
                                        'images', '*'))
      paths.each { |p| sh "cp #{p} #{img_dir}" }
    end
  end
end
