# -*- coding: utf-8 -*-
Grit::Tree.module_eval do
  def /(file)
    if file =~ /\//
      file.split("/").inject(self) {|acc, x| acc/x } rescue nil
    else
      self.contents.find {|c| 
        c.name.force_encoding("utf-8") == file.force_encoding("utf-8")
      }
    end
  end
end
