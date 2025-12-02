/// 🔹 قائمة أنواع الخدمات المطلوبة من المستخدمين (طلب خدمة)
const List<String> kRequestServiceTypes = [
  'Plumbing', // سباكة
  'Electrician', // كهرباء
  'Painting', // دهان
  'Cleaning', // تنظيف منازل
  'Carpentry', // نجارة
  'Gardening', // بستنة
  'Car Repair', // تصليح سيارات
  'Appliance Repair', // تصليح أجهزة كهربائية
  'Moving', // نقل أثاث
  'Babysitting', // جليسة أطفال
  'Elder Care', // رعاية كبار السن
  'Tutoring', // دروس خصوصية
  'Computer Repair', // صيانة كمبيوتر
  'IT Support', // دعم تقني
  'Photography', // تصوير مناسبات
  'Makeup Artist', // تجميل
  'Hairdresser', // حلاق
  'Catering', // طبخ / بوفيه
  'Event Planning', // تنظيم مناسبات
  'Delivery', // توصيل طلبات
  'Laundry', // غسيل ملابس
  'Tailoring', // خياطة
  'Home Security', // تركيب كاميرات
  'Construction', // أعمال بناء
  'Roof Repair', // تصليح أسطح
  'Floor Tiling', // تبليط
  'Furniture Assembly', // تركيب أثاث
  'Interior Design', // تصميم داخلي
  'Pool Cleaning', // تنظيف مسابح
  'Pest Control', // مكافحة حشرات
  'Water Tank Cleaning', // تنظيف خزانات
  'Window Cleaning', // تنظيف شبابيك
  'Car Wash', // غسيل سيارات
  'Sofa Cleaning', // تنظيف كنب
  'House Disinfection', // تعقيم منازل
  'Locksmith', // فتح أقفال
  'Roof Waterproofing', // عزل أسطح
  'Wallpaper Installation', // تركيب ورق جدران
  'Curtain Installation', // تركيب ستائر
  'Fence Repair', // تصليح سور
  'Gate Welding', // لحام بوابات
  'Glass Replacement', // تغيير زجاج
  'Air Conditioner Repair', // تصليح مكيف
  'Satellite Installation', // تركيب دش
  'Lighting Setup', // تركيب إضاءة
  'WiFi Installation', // تركيب إنترنت
  'TV Mounting', // تثبيت تلفاز
  'Drain Cleaning', // فتح مجاري
  'Septic Tank Pumping', // شفط بيارات
  'Snow Removal', // إزالة ثلوج
  'Garbage Removal', // إزالة نفايات
  'Pet Sitting', // رعاية حيوانات
  'Dog Walking', // تنزه الكلاب
  'Home Painting', // دهان منازل
  'Kitchen Renovation', // تجديد مطبخ
  'Bathroom Renovation', // تجديد حمام
  'Tile Polishing', // تلميع سيراميك
  'Alarm Installation', // تركيب إنذار
  'Solar Panel Cleaning', // تنظيف ألواح شمسية
  'Garage Door Repair', // تصليح باب كراج
  'Fence Painting', // دهان سياج
  'Roof Painting', // دهان سقف
  'Furniture Repair', // تصليح أثاث
  'Window Tinting', // تظليل نوافذ
  'Computer Setup', // إعداد كمبيوتر
  'Printer Repair', // تصليح طابعة
  'Smart Home Setup', // تركيب بيت ذكي
  'Mobile Repair', // تصليح موبايل
  'Tablet Repair', // تصليح تابلت
  'Laptop Cleaning', // تنظيف لابتوب
  'Virus Removal', // إزالة فيروسات
  'Data Recovery', // استرجاع بيانات
  'Network Setup', // إعداد شبكة
  'CCTV Installation', // تركيب كاميرات مراقبة
  'Doorbell Repair', // تصليح جرس
  'Ceiling Fan Installation', // تركيب مروحة سقف
  'Electric Gate Setup', // تركيب بوابة كهربائية
  'Car Battery Jumpstart', // شحن بطارية السيارة
  'Tire Change', // تبديل دواليب
  'Oil Change', // تبديل زيت
  'Car Interior Cleaning', // تنظيف داخل السيارة
  'Engine Diagnostic', // فحص محرك
  'Car Detailing', // تلميع سيارة
  'Tow Truck', // طلب سحب سيارة
  'Gas Delivery', // توصيل غاز
  'Water Delivery', // توصيل مياه
  'Grocery Delivery', // توصيل أغراض
  'Courier Pickup', // استلام طرد
  'Home Nurse', // ممرضة منزلية
  'Physiotherapy', // علاج طبيعي
  'Psychological Support', // دعم نفسي
  'Speech Therapy', // علاج نطق
  'Wheelchair Repair', // تصليح كرسي متحرك
  'Personal Trainer', // مدرب شخصي
  'Nutritionist', // أخصائي تغذية
  'Home Workout Help', // مدرب منزلي
  'Other', // أخرى
];

/// 🔹 قائمة أنواع الخدمات التي يمكن للمستخدم تقديمها (تقديم خدمة)
const List<String> kOfferServiceTypes = [
  'Plumber', // فني سباكة
  'Electrician', // فني كهرباء
  'Painter', // دهّان
  'Cleaner', // عامل تنظيف
  'Carpenter', // نجّار
  'Gardener', // بستاني
  'Mechanic', // ميكانيكي سيارات
  'AC Technician', // فني مكيفات
  'IT Specialist', // مختص حاسوب
  'Software Developer', // مبرمج
  'Graphic Designer', // مصمم جرافيك
  'Photographer', // مصور محترف
  'Videographer', // مصور فيديو
  'Chef', // طباخ
  'Waiter', // نادل
  'Barista', // صانع قهوة
  'Driver', // سائق
  'Delivery Person', // عامل توصيل
  'Event Organizer', // منظم مناسبات
  'Wedding Planner', // منسق زفاف
  'DJ', // منسق موسيقى
  'Hair Stylist', // مصفف شعر
  'Makeup Artist', // خبيرة تجميل
  'Fashion Designer', // مصمم أزياء
  'Tailor', // خياط
  'Teacher', // معلم
  'Tutor', // مدرس خصوصي
  'Translator', // مترجم
  'Editor', // محرر نصوص
  'Writer', // كاتب محتوى
  'Social Media Manager', // مدير سوشال ميديا
  'SEO Expert', // خبير تحسين محركات البحث
  'Content Creator', // منشئ محتوى
  'Web Developer', // مطور مواقع
  'App Developer', // مطور تطبيقات
  'Cybersecurity Expert', // خبير أمن معلومات
  'System Administrator', // مدير أنظمة
  'Network Technician', // فني شبكات
  'Database Manager', // مدير قاعدة بيانات
  'UI/UX Designer', // مصمم واجهات
  '3D Modeler', // مصمم ثلاثي الأبعاد
  'Architect', // مهندس معماري
  'Civil Engineer', // مهندس مدني
  'Mechanical Engineer', // مهندس ميكانيك
  'Electrical Engineer', // مهندس كهرباء
  'Surveyor', // مسّاح أراضٍ
  'Interior Decorator', // مصمم ديكور داخلي
  'Landscape Designer', // مصمم حدائق
  'Real Estate Agent', // وسيط عقاري
  'Lawyer', // محامي
  'Accountant', // محاسب
  'Consultant', // مستشار
  'Marketing Expert', // خبير تسويق
  'Financial Advisor', // مستشار مالي
  'Insurance Agent', // وكيل تأمين
  'Dentist', // طبيب أسنان
  'Doctor', // طبيب
  'Nurse', // ممرض
  'Physiotherapist', // أخصائي علاج طبيعي
  'Psychologist', // أخصائي نفسي
  'Veterinarian', // طبيب بيطري
  'Pharmacist', // صيدلي
  'Nutritionist', // أخصائي تغذية
  'Personal Trainer', // مدرب لياقة
  'Yoga Instructor', // مدرب يوغا
  'Massage Therapist', // مدلك
  'Chiropractor', // أخصائي تقويم
  'Security Guard', // حارس أمن
  'Bodyguard', // حارس شخصي
  'Cleaner', // عامل تنظيف
  'Janitor', // منظف مباني
  'Technician', // فني
  'Blacksmith', // حداد
  'Welder', // لحام
  'Mason', // بناء
  'Tile Setter', // مركب بلاط
  'Driver - Truck', // سائق شاحنة
  'Taxi Driver', // سائق تاكسي
  'Courier', // مندوب توصيل
  'Mechanic Assistant', // مساعد ميكانيكي
  'Chef Assistant', // مساعد طباخ
  'Sound Engineer', // مهندس صوت
  'Lighting Technician', // فني إضاءة
  'Stage Builder', // بناء مسرح
  'Decorator', // مزين مناسبات
  'Florist', // بائع زهور
  'Pet Groomer', // مزيّن حيوانات
  'Dog Trainer', // مدرب كلاب
  'Car Washer', // مغسل سيارات
  'Delivery Partner', // موصل طلبات
  'Maintenance Worker', // عامل صيانة
  'Refrigeration Technician', // فني ثلاجات
  'Elevator Technician', // فني مصاعد
  'Window Installer', // مركب نوافذ
  'Roof Repairer', // مصلّح أسطح
  'Plasterer', // جبّاص
  'Painter Assistant', // مساعد دهان
  'Iron Worker', // عامل حديد
  'Other', // أخرى
];
