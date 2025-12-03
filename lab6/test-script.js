const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log("Start seeding...");

  const role = await prisma.roles.create({
    data: { role_name: 'STUDENT_TEST' }
  });

  const user = await prisma.users.create({
    data: {
      email: 'lab6@test.com',
      first_name: 'Lab',
      last_name: 'Six',
      password_hash: '12345',
      role_id: role.role_id,
      phone: '+380991112233'
    }
  });
  console.log(`Created User: ${user.email} with phone: ${user.phone}`);

  const category = await prisma.categories.create({ data: { category_name: 'IT' } });
  const course = await prisma.courses.create({
    data: {
      title: 'Prisma Course',
      instructor_id: user.user_id,
      category_id: category.category_id,
      summary: 'This is a summary'
    }
  });
  
  const module = await prisma.modules.create({
    data: { title: 'Module 1', course_id: course.course_id, order_index: 1 }
  });

  const contentType = await prisma.content_types.create({ data: { type_name: 'PDF' } });
  
  const lesson = await prisma.lessons.create({
    data: {
      title: 'Intro Lesson',
      module_id: module.module_id,
      content_type_id: contentType.content_type_id,
      order_index: 1
    }
  });

  const material = await prisma.material.create({
    data: {
      title: 'Lab 6 Guide',
      url: 'https://example.com/guide.pdf',
      lesson_id: lesson.lesson_id
    }
  });

  console.log("------------------------------------------------");
  console.log("SUCCESS! Created Material record in DB:");
  console.log(material);
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });