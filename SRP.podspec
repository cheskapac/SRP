Pod::Spec.new do |spec|
  spec.name         = "SRP"
  spec.version      = "3.2.0"
  spec.summary      = "Secure Remote Password is a authentication protocol to prove your identity to another party, using a password, but without ever revealing that password to other parties. Not even the party you are proving your identity."
  spec.homepage     = "http://boukehaarsma.nl/SRP"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Bouke Haarsma" => "bouke@haarsma.eu", "Paulius Cesekas" => "cheskapac@gmail.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/cheskapac/SRP.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/*"
  spec.dependency "BlueCryptor", "~> 1.0.28"
  spec.dependency "BigInt.swift", "~> 1.0.0"
end
