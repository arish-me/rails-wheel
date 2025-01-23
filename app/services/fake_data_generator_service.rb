require 'open-uri'
class FakeDataGeneratorService
 def self.generate
    # Create Courses
    5.times do
      course = Course.create!(
        name: Faker::Educator.course_name,
        subtitle: Faker::Marketing.buzzwords,
        description: Faker::Lorem.paragraph(sentence_count: 5),
        slug: Faker::Internet.slug,
        custom_slug: Faker::Internet.slug,
        duration: "#{rand(10..50)} hours"
      )

      # Attach a random image to the course avatar
      avatar_url = "https://picsum.photos/id/1/200/200" # Example random image URL
      course.avatar.attach(
        io: URI.open(avatar_url),
        filename: "course_avatar_#{course.id}.jpg",
        content_type: 'image/jpeg'
      )

      # Create Topics for Each Course
      rand(15..20).times do
        topic = course.topics.create!(
          heading: Faker::Educator.subject,
          slug: Faker::Internet.slug,
          duration: "#{rand(1..5)} hours",
          position: course.topics.size + 1
        )

        # Create Chapters for Each Topic
        rand(2..5).times do
          topic.chapters.create!(
            name: Faker::Book.title,
            content: Faker::Lorem.paragraph(sentence_count: 10),
            slug: Faker::Internet.slug,
            duration: "#{rand(30..90)} minutes",
            position: topic.chapters.size + 1
          )
        end
      end
    end
  end
end