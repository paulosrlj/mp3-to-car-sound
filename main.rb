require 'streamio-ffmpeg'
require 'ruby-progressbar'
require 'fileutils'

# Convert mp3 files to mp3 files with 320kbps
main_folder_path = ARGV[0]
output_folder = ARGV[1]

mp3_files = Dir.glob("#{main_folder_path}/**/*.mp3")

Dir.glob("#{main_folder_path}/**/*.mp3").group_by { |file| File.dirname(file) }.each do |folder, files|
  folder_name = folder.split("/")[-1]
  FileUtils.mkdir_p("#{output_folder}/#{folder_name}")
  p "Processing folder: #{folder_name}"

  files.each_with_index do |file, index|
    original_name = File.basename(file, ".mp3")
    converted_file = File.join(output_folder, folder_name, "#{original_name}_320kbps.mp3")

    progressbar = ProgressBar.create(
      title: "Converting... #{index + 1}/#{files.size}",
      total: 100,
      format: '%t |%B| %p%%'
    )

    # Convert to 320kbps, remove image stream, and handle other necessary options
    movie = FFMPEG::Movie.new(file)

    # Check if the file has image or video attached to it
    options = {
      audio_codec: 'libmp3lame',
      audio_bitrate: '320k',
      metadata: false,
      analyzeduration: 5000000,
      probesize: 5000000,
      custom: ['-vn']  # Ignore images and videos
    }

    # Convert
    movie.transcode(converted_file, options) do |progress|
      progressbar.progress = (progress * 100).round
    end
  end
end

p "Done - Converted #{mp3_files.size} files"
