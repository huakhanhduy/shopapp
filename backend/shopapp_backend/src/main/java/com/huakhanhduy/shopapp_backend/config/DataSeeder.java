package com.huakhanhduy.shopapp_backend.config;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.entity.ProductType;
import com.huakhanhduy.shopapp_backend.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;


@Component
public class DataSeeder implements CommandLineRunner {


    private final RoleRepository roleRepository;
    private final StaffAccountRepository staffAccountRepository;
    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final TagRepository tagRepository;
    private final ProductTagRepository productTagRepository;
    private final ProductVariantRepository productVariantRepository;
    private final PromoCodeRepository promoCodeRepository;
    private final ReviewRepository reviewRepository;
    private final CustomerRepository customerRepository;
    private final ShippingAddressRepository shippingAddressRepository;
    private final PaymentCardRepository paymentCardRepository;
    private final CountryRepository countryRepository;
    private final SupplierRepository supplierRepository;
    private final ProductSupplierRepository productSupplierRepository;
    private final PasswordEncoder passwordEncoder;
    private final OrderDetailRepository orderDetailRepository;
    private final OrderRepository orderRepository;
    private final CartItemRepository cartItemRepository;
    private final CartRepository cartRepository;
    private final WishlistItemRepository wishlistItemRepository;

    public DataSeeder(
            RoleRepository roleRepository,
            StaffAccountRepository staffAccountRepository,
            CategoryRepository categoryRepository,
            ProductRepository productRepository,
            ProductCategoryRepository productCategoryRepository,
            TagRepository tagRepository,
            ProductTagRepository productTagRepository,
            ProductVariantRepository productVariantRepository,
            PromoCodeRepository promoCodeRepository,
            ReviewRepository reviewRepository,
            CustomerRepository customerRepository,
            ShippingAddressRepository shippingAddressRepository,
            PaymentCardRepository paymentCardRepository,
            CountryRepository countryRepository,
            SupplierRepository supplierRepository,
            ProductSupplierRepository productSupplierRepository,
            PasswordEncoder passwordEncoder,
            OrderDetailRepository orderDetailRepository,
            OrderRepository orderRepository,
            CartItemRepository cartItemRepository,
            CartRepository cartRepository,
            WishlistItemRepository wishlistItemRepository
    ) {
        this.roleRepository = roleRepository;
        this.staffAccountRepository = staffAccountRepository;
        this.categoryRepository = categoryRepository;
        this.productRepository = productRepository;
        this.productCategoryRepository = productCategoryRepository;
        this.tagRepository = tagRepository;
        this.productTagRepository = productTagRepository;
        this.productVariantRepository = productVariantRepository;
        this.promoCodeRepository = promoCodeRepository;
        this.reviewRepository = reviewRepository;
        this.customerRepository = customerRepository;
        this.shippingAddressRepository = shippingAddressRepository;
        this.paymentCardRepository = paymentCardRepository;
        this.countryRepository = countryRepository;
        this.supplierRepository = supplierRepository;
        this.productSupplierRepository = productSupplierRepository;
        this.passwordEncoder = passwordEncoder;
        this.orderDetailRepository = orderDetailRepository;
        this.orderRepository = orderRepository;
        this.cartItemRepository = cartItemRepository;
        this.cartRepository = cartRepository;
        this.wishlistItemRepository = wishlistItemRepository;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        if (roleRepository.count() > 0 && productRepository.count() > 0) {
            System.out.println("=== ShopApp DataSeeder: Dữ liệu đã tồn tại trong database, bỏ qua bước Seed để giữ lại giỏ hàng/địa chỉ ===");
            return;
        }
        System.out.println("=== ShopApp DataSeeder: Bắt đầu xóa dữ liệu cũ và tạo dữ liệu mới ===");

        // ============================================================
        // BƯỚC 0: XÓA DỮ LIỆU CŨ (theo thứ tự phụ thuộc khóa ngoại)
        // ============================================================
        System.out.println(">> Xóa dữ liệu cũ...");
        wishlistItemRepository.deleteAll();
        orderDetailRepository.deleteAll();
        orderRepository.deleteAll();
        cartItemRepository.deleteAll();
        cartRepository.deleteAll();
        reviewRepository.deleteAll();
        productVariantRepository.deleteAll();
        productSupplierRepository.deleteAll();
        productTagRepository.deleteAll();
        productCategoryRepository.deleteAll();
        productRepository.deleteAll();
        supplierRepository.deleteAll();
        tagRepository.deleteAll();
        categoryRepository.deleteAll();
        promoCodeRepository.deleteAll();
        paymentCardRepository.deleteAll();
        shippingAddressRepository.deleteAll();

        // Ép buộc Hibernate đồng bộ việc xóa dữ liệu cũ xuống database trước khi tiếp tục
        wishlistItemRepository.flush();
        orderDetailRepository.flush();
        orderRepository.flush();
        cartItemRepository.flush();
        cartRepository.flush();
        reviewRepository.flush();
        productVariantRepository.flush();
        productSupplierRepository.flush();
        productTagRepository.flush();
        productCategoryRepository.flush();
        productRepository.flush();
        supplierRepository.flush();
        tagRepository.flush();
        categoryRepository.flush();
        promoCodeRepository.flush();
        paymentCardRepository.flush();
        shippingAddressRepository.flush();

        System.out.println(">> Xóa dữ liệu cũ hoàn tất.");

        // ============================================================
        // BƯỚC 1: ROLES
        // ============================================================
        Role userRole = roleRepository.findByRoleName("ROLE_USER").orElseGet(() -> {
            Role r = new Role("ROLE_USER", "READ_PRODUCTS,WRITE_ORDERS");
            return roleRepository.save(r);
        });
        Role adminRole = roleRepository.findByRoleName("ROLE_ADMIN").orElseGet(() -> {
            Role r = new Role("ROLE_ADMIN", "ALL_PRIVILEGES");
            return roleRepository.save(r);
        });

        // ============================================================
        // BƯỚC 2: STAFF ACCOUNTS
        // ============================================================
        StaffAccount customerStaff = staffAccountRepository.findByEmail("user@gmail.com").orElseGet(() -> {
            StaffAccount sa = new StaffAccount();
            sa.setFirstName("Huy");
            sa.setLastName("Hua Khánh");
            sa.setEmail("user@gmail.com");
            sa.setPhoneNumber("0987654321");
            sa.setPasswordHash(passwordEncoder.encode("1"));
            sa.setRole(userRole);
            sa.setActive(true);
            return staffAccountRepository.save(sa);
        });

        StaffAccount adminStaff = staffAccountRepository.findByEmail("admin@gmail.com").orElseGet(() -> {
            StaffAccount sa = new StaffAccount();
            sa.setFirstName("Admin");
            sa.setLastName("ShopApp");
            sa.setEmail("admin@gmail.com");
            sa.setPhoneNumber("0123456789");
            sa.setPasswordHash(passwordEncoder.encode("1"));
            sa.setRole(adminRole);
            sa.setActive(true);
            return staffAccountRepository.save(sa);
        });

        // ============================================================
        // BƯỚC 3: CUSTOMER PROFILES
        // ============================================================
        Customer customerCust = customerRepository.findByEmail("user@gmail.com").orElseGet(() -> {
            Customer c = new Customer();
            c.setFirstName("Huy");
            c.setLastName("Hua Khánh");
            c.setEmail("user@gmail.com");
            c.setPasswordHash(passwordEncoder.encode("1"));
            c.setActive(true);
            return customerRepository.save(c);
        });

        Customer adminCust = customerRepository.findByEmail("admin@gmail.com").orElseGet(() -> {
            Customer c = new Customer();
            c.setFirstName("Admin");
            c.setLastName("ShopApp");
            c.setEmail("admin@gmail.com");
            c.setPasswordHash(passwordEncoder.encode("1"));
            c.setActive(true);
            return customerRepository.save(c);
        });

        // ============================================================
        // BƯỚC 4: COUNTRIES
        // ============================================================
        Country vn = saveCountry("VN", "Vietnam", "VIETNAM", "VNM", (short)704, 84);
        Country us = saveCountry("US", "United States", "UNITED STATES", "USA", (short)840, 1);
        Country de = saveCountry("DE", "Germany", "GERMANY", "DEU", (short)276, 49);
        Country it = saveCountry("IT", "Italy", "ITALY", "ITA", (short)380, 39);
        Country se = saveCountry("SE", "Sweden", "SWEDEN", "SWE", (short)752, 46);
        Country jp = saveCountry("JP", "Japan", "JAPAN", "JPN", (short)392, 81);
        Country uk = saveCountry("GB", "United Kingdom", "UNITED KINGDOM", "GBR", (short)826, 44);

        // ============================================================
        // BƯỚC 5: SUPPLIERS
        // ============================================================
        Supplier nike    = saveSupplier("Nike",     "Nike Inc.",            "15036716453", "One Bowerman Dr, Beaverton, OR",          us,  adminStaff);
        Supplier adidas  = saveSupplier("Adidas",   "Adidas AG",            "499132840",   "Adi-Dassler-Straße 1, Herzogenaurach",    de,  adminStaff);
        Supplier zara    = saveSupplier("Zara",     "Zara SA",              "34912345678", "Arteixo, A Coruña, Spain",                se,  adminStaff);
        Supplier hm      = saveSupplier("H&M",      "H&M Group",            "4687965500",  "Mäster Samuelsgatan 46, Stockholm",       se,  adminStaff);
        Supplier levis   = saveSupplier("Levi's",   "Levi Strauss & Co.",   "18008725384", "1155 Battery St, San Francisco, CA",      us,  adminStaff);
        Supplier gucci   = saveSupplier("Gucci",    "Gucci S.p.A.",         "3905575921",  "Via Tornabuoni 73r, Florence",            it,  adminStaff);
        Supplier uniqlo  = saveSupplier("Uniqlo",   "Fast Retailing Co.",   "81357774611", "717-1 Sayama, Yamaguchi",                 jp,  adminStaff);
        Supplier burberry= saveSupplier("Burberry", "Burberry Group PLC",   "4420306562",  "Horseferry House, London",                uk,  adminStaff);
        Supplier puma    = saveSupplier("Puma",     "Puma SE",              "4991324840",  "PUMA Way 1, Herzogenaurach",              de,  adminStaff);
        Supplier gap     = saveSupplier("Gap",      "Gap Inc.",             "16504787000", "2 Folsom St, San Francisco, CA",          us,  adminStaff);

        // ============================================================
        // BƯỚC 6: CATEGORIES (Parent)
        // ============================================================
        Category women = saveCategory("Women", "Bộ sưu tập thời trang nữ",  "icons/women.png", "assets/images/shop1.png", true, null, adminStaff);
        Category men   = saveCategory("Men",   "Bộ sưu tập thời trang nam",  "icons/men.png",   "assets/images/shop2.png", true, null, adminStaff);
        Category kids  = saveCategory("Kids",  "Bộ sưu tập trẻ em",          "icons/kids.png",  "assets/images/shop3.png", true, null, adminStaff);

        // Subcategories Women
        Category womenTops    = saveCategory("Tops",     "Áo nữ thời trang",        "icons/tops.png",    "assets/images/shop4.png",  true, women, adminStaff);
        Category womenShirts  = saveCategory("Shirts",   "Áo sơ mi nữ thanh lịch",  "icons/shirts.png",  "assets/images/shop5.png",  true, women, adminStaff);
        Category womenKnit    = saveCategory("Knitwear", "Áo len dệt kim nữ",        "icons/knitwear.png","assets/images/shop6.png",  true, women, adminStaff);
        Category womenHoodies = saveCategory("Hoodies",  "Áo hoodie nữ",             "icons/hoodies.png", "assets/images/shop4.png",  true, women, adminStaff);
        Category womenShoes   = saveCategory("Shoes",    "Giày dép nữ",              "icons/shoes.png",   "assets/images/shop5.png",  true, women, adminStaff);
        Category womenJeans   = saveCategory("Jeans",    "Quần jeans nữ",            "icons/jeans.png",   "assets/images/shop6.png",  true, women, adminStaff);

        // Subcategories Men
        Category menTops    = saveCategory("Tops",     "Áo nam thời trang",         "icons/tops.png",    "assets/images/shop4.png",  true, men, adminStaff);
        Category menShirts  = saveCategory("Shirts",   "Áo sơ mi nam thanh lịch",   "icons/shirts.png",  "assets/images/shop5.png",  true, men, adminStaff);
        Category menKnit    = saveCategory("Knitwear", "Áo len dệt kim nam",         "icons/knitwear.png","assets/images/shop6.png",  true, men, adminStaff);
        Category menHoodies = saveCategory("Hoodies",  "Áo hoodie nam",              "icons/hoodies.png", "assets/images/shop4.png",  true, men, adminStaff);
        Category menShoes   = saveCategory("Shoes",    "Giày dép nam",               "icons/shoes.png",   "assets/images/shop5.png",  true, men, adminStaff);
        Category menJeans   = saveCategory("Jeans",    "Quần jeans nam",             "icons/jeans.png",   "assets/images/shop6.png",  true, men, adminStaff);

        // Subcategories Kids
        Category kidsTops    = saveCategory("Tops",     "Áo trẻ em",                "icons/tops.png",    "assets/images/shop4.png",  true, kids, adminStaff);
        Category kidsShirts  = saveCategory("Shirts",   "Áo sơ mi trẻ em",          "icons/shirts.png",  "assets/images/shop5.png",  true, kids, adminStaff);
        Category kidsKnit    = saveCategory("Knitwear", "Áo len trẻ em",             "icons/knitwear.png","assets/images/shop6.png",  true, kids, adminStaff);
        Category kidsHoodies = saveCategory("Hoodies",  "Áo hoodie trẻ em",          "icons/hoodies.png", "assets/images/shop4.png",  true, kids, adminStaff);
        Category kidsShoes   = saveCategory("Shoes",    "Giày trẻ em",               "icons/shoes.png",   "assets/images/shop5.png",  true, kids, adminStaff);
        Category kidsJeans   = saveCategory("Jeans",    "Quần jeans trẻ em",         "icons/jeans.png",   "assets/images/shop6.png",  true, kids, adminStaff);

        // ============================================================
        // BƯỚC 7: TAGS
        // ============================================================
        Tag saleTag    = saveTag("Sale",      "icons/sale.png");
        Tag newTag     = saveTag("Mới Về",    "icons/new.png");
        Tag trendTag   = saveTag("Hot Trend", "icons/trend.png");
        Tag menTag     = saveTag("Men",       "icons/men.png");
        Tag womenTag   = saveTag("Women",     "icons/women.png");
        Tag kidsTag    = saveTag("Kids",      "icons/kids.png");
        Tag luxuryTag  = saveTag("Luxury",    "icons/luxury.png");
        Tag sportTag   = saveTag("Sport",     "icons/sport.png");
        Tag casualTag  = saveTag("Casual",    "icons/casual.png");
        Tag premiumTag = saveTag("Premium",   "icons/premium.png");

        // ============================================================
        // BƯỚC 8: PROMO CODES
        // ============================================================
        savePromoCode("SUMMER50", 50);
        savePromoCode("WELCOME10", 10);
        savePromoCode("VIP20", 20);
        savePromoCode("FLASH30", 30);

        // ============================================================
        // BƯỚC 9: PRODUCTS (5 sản phẩm mỗi subcategory - với ảnh đúng phân loại)
        // ============================================================
        System.out.println(">> Seeding sản phẩm...");

        // ============================================================
        // ---- WOMEN > TOPS (5 sản phẩm) ----
        // ============================================================
        p("Floral Wrap Crop Top",          "floral-wrap-crop-top",           "SKU-W-TOP-001", "assets/images/pro_w_top_1.png",
          320000.0, 256000.0, ProductType.TSHIRT, womenTops,
          List.of(womenTag, newTag),    zara,    adminStaff, customerCust, adminCust, false);

        p("Satin Ruffle Blouse",           "satin-ruffle-blouse",            "SKU-W-TOP-002", "assets/images/pro_w_top_2.png",
          480000.0, 384000.0, ProductType.TSHIRT, womenTops,
          List.of(womenTag, trendTag),  gucci,   adminStaff, customerCust, adminCust, false);

        p("Ribbed Crop Tank Top",          "ribbed-crop-tank-top",           "SKU-W-TOP-003", "assets/images/pro_w_top_3.png",
          195000.0, 156000.0, ProductType.TSHIRT, womenTops,
          List.of(womenTag, saleTag),   hm,      adminStaff, customerCust, adminCust, false);

        p("Elegant Off-Shoulder Top",      "elegant-off-shoulder-top",       "SKU-W-TOP-004", "assets/images/pro_w_top_4.png",
          390000.0, 312000.0, ProductType.TSHIRT, womenTops,
          List.of(womenTag, luxuryTag), gucci,   adminStaff, customerCust, adminCust, false);

        p("Cotton Puff Sleeve Top",        "cotton-puff-sleeve-top",         "SKU-W-TOP-005", "assets/images/pro_w_top_5.png",
          270000.0, 216000.0, ProductType.TSHIRT, womenTops,
          List.of(womenTag, casualTag), uniqlo,  adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- WOMEN > SHIRTS (5 sản phẩm) ----
        // ============================================================
        p("Classic White Linen Shirt",     "classic-white-linen-shirt",      "SKU-W-SHT-001", "assets/images/pro_w_shirt_1.png",
          350000.0, 280000.0, ProductType.SHIRT, womenShirts,
          List.of(womenTag, casualTag), uniqlo,   adminStaff, customerCust, adminCust, false);

        p("Striped Button-Down Shirt",     "striped-button-down-shirt",      "SKU-W-SHT-002", "assets/images/pro_w_shirt_2.png",
          410000.0, 328000.0, ProductType.SHIRT, womenShirts,
          List.of(womenTag, trendTag),   zara,    adminStaff, customerCust, adminCust, false);

        p("Oversized Flannel Shirt",       "oversized-flannel-shirt",        "SKU-W-SHT-003", "assets/images/pro_w_shirt_3.png",
          460000.0, 368000.0, ProductType.SHIRT, womenShirts,
          List.of(womenTag, newTag),     hm,      adminStaff, customerCust, adminCust, false);

        p("Silk Blend Office Shirt",       "silk-blend-office-shirt",        "SKU-W-SHT-004", "assets/images/pro_w_shirt_4.png",
          650000.0, 520000.0, ProductType.SHIRT, womenShirts,
          List.of(womenTag, luxuryTag),  gucci,   adminStaff, customerCust, adminCust, false);

        p("Chambray Casual Shirt",         "chambray-casual-shirt",          "SKU-W-SHT-005", "assets/images/pro_w_shirt_5.png",
          295000.0, 236000.0, ProductType.SHIRT, womenShirts,
          List.of(womenTag, saleTag),    gap,     adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- WOMEN > KNITWEAR (5 sản phẩm) ----
        // ============================================================
        p("Cozy Chunky Knit Sweater",      "cozy-chunky-knit-sweater",       "SKU-W-KNT-001", "assets/images/pro_w_knit_1.png",
          520000.0, 416000.0, ProductType.TSHIRT, womenKnit,
          List.of(womenTag, newTag),     hm,      adminStaff, customerCust, adminCust, false);

        p("Cashmere V-Neck Pullover",      "cashmere-v-neck-pullover",       "SKU-W-KNT-002", "assets/images/pro_w_knit_2.png",
          980000.0, 784000.0, ProductType.TSHIRT, womenKnit,
          List.of(womenTag, luxuryTag),  burberry,adminStaff, customerCust, adminCust, false);

        p("Turtleneck Ribbed Sweater",     "turtleneck-ribbed-sweater",      "SKU-W-KNT-003", "assets/images/pro_w_knit_3.png",
          440000.0, 352000.0, ProductType.TSHIRT, womenKnit,
          List.of(womenTag, trendTag),   zara,    adminStaff, customerCust, adminCust, false);

        p("Open Front Cardigan",           "open-front-cardigan",            "SKU-W-KNT-004", "assets/images/pro_w_knit_4.png",
          380000.0, 304000.0, ProductType.TSHIRT, womenKnit,
          List.of(womenTag, casualTag),  uniqlo,  adminStaff, customerCust, adminCust, false);

        p("Cable Knit Long Cardigan",      "cable-knit-long-cardigan",       "SKU-W-KNT-005", "assets/images/pro_w_knit_5.png",
          560000.0, 448000.0, ProductType.TSHIRT, womenKnit,
          List.of(womenTag, saleTag),    hm,      adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- WOMEN > HOODIES (5 sản phẩm) ----
        // ============================================================
        p("Pastel Pink Pullover Hoodie",   "pastel-pink-pullover-hoodie",    "SKU-W-HOD-001", "assets/images/pro_w_hoodie_1.png",
          420000.0, 336000.0, ProductType.HOODIE, womenHoodies,
          List.of(womenTag, newTag),     hm,      adminStaff, customerCust, adminCust, false);

        p("Cropped Zip-Up Hoodie",         "cropped-zip-up-hoodie",          "SKU-W-HOD-002", "assets/images/pro_w_hoodie_2.png",
          490000.0, 392000.0, ProductType.HOODIE, womenHoodies,
          List.of(womenTag, trendTag),   nike,    adminStaff, customerCust, adminCust, false);

        p("Oversized Fleece Hoodie",       "oversized-fleece-hoodie",        "SKU-W-HOD-003", "assets/images/pro_w_hoodie_3.png",
          530000.0, 424000.0, ProductType.HOODIE, womenHoodies,
          List.of(womenTag, casualTag),  adidas,  adminStaff, customerCust, adminCust, false);

        p("Graphic Print Hoodie",          "graphic-print-hoodie-women",     "SKU-W-HOD-004", "assets/images/pro_w_hoodie_4.png",
          360000.0, 288000.0, ProductType.HOODIE, womenHoodies,
          List.of(womenTag, saleTag),    gap,     adminStaff, customerCust, adminCust, false);

        p("Velvet Luxe Hoodie",            "velvet-luxe-hoodie",             "SKU-W-HOD-005", "assets/images/pro_w_hoodie_5.png",
          680000.0, 544000.0, ProductType.HOODIE, womenHoodies,
          List.of(womenTag, luxuryTag),  gucci,   adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- WOMEN > SHOES (5 sản phẩm) ----
        // ============================================================
        p("Classic White Sneakers",        "classic-white-sneakers-women",   "SKU-W-SHO-001", "assets/images/pro_w_shoe_1.png",
          650000.0, 520000.0, ProductType.SNEAKER, womenShoes,
          List.of(womenTag, trendTag),   adidas,  adminStaff, customerCust, adminCust, true);

        p("Slip-On Canvas Shoes",          "slip-on-canvas-shoes-women",     "SKU-W-SHO-002", "assets/images/pro_w_shoe_2.png",
          380000.0, 304000.0, ProductType.SNEAKER, womenShoes,
          List.of(womenTag, casualTag),  uniqlo,  adminStaff, customerCust, adminCust, true);

        p("Air Cushion Running Shoes",     "air-cushion-running-shoes-w",    "SKU-W-SHO-003", "assets/images/pro_w_shoe_3.png",
          870000.0, 696000.0, ProductType.SNEAKER, womenShoes,
          List.of(womenTag, sportTag),   nike,    adminStaff, customerCust, adminCust, true);

        p("Chunky Platform Sneakers",      "chunky-platform-sneakers-women", "SKU-W-SHO-004", "assets/images/pro_w_shoe_4.png",
          760000.0, 608000.0, ProductType.SNEAKER, womenShoes,
          List.of(womenTag, newTag),     puma,    adminStaff, customerCust, adminCust, true);

        p("Premium Leather Loafers",       "premium-leather-loafers-women",  "SKU-W-SHO-005", "assets/images/pro_w_shoe_5.png",
          1200000.0, 960000.0, ProductType.SNEAKER, womenShoes,
          List.of(womenTag, luxuryTag),  gucci,   adminStaff, customerCust, adminCust, true);

        // ============================================================
        // ---- WOMEN > JEANS (5 sản phẩm) ----
        // ============================================================
        p("High Waist Skinny Jeans",       "high-waist-skinny-jeans-women",  "SKU-W-JNS-001", "assets/images/pro_w_jean_1.png",
          490000.0, 392000.0, ProductType.JEANS, womenJeans,
          List.of(womenTag, trendTag),   levis,   adminStaff, customerCust, adminCust, false);

        p("Wide Leg Denim Jeans",          "wide-leg-denim-jeans-women",     "SKU-W-JNS-002", "assets/images/pro_w_jean_2.png",
          540000.0, 432000.0, ProductType.JEANS, womenJeans,
          List.of(womenTag, newTag),     zara,    adminStaff, customerCust, adminCust, false);

        p("Distressed Ripped Jeans",       "distressed-ripped-jeans-women",  "SKU-W-JNS-003", "assets/images/pro_w_jean_3.png",
          450000.0, 360000.0, ProductType.JEANS, womenJeans,
          List.of(womenTag, casualTag),  levis,   adminStaff, customerCust, adminCust, false);

        p("Vintage Mom Jeans",             "vintage-mom-jeans",              "SKU-W-JNS-004", "assets/images/pro_w_jean_4.png",
          480000.0, 384000.0, ProductType.JEANS, womenJeans,
          List.of(womenTag, trendTag),   gap,     adminStaff, customerCust, adminCust, false);

        p("Cropped Flare Jeans",           "cropped-flare-jeans-women",      "SKU-W-JNS-005", "assets/images/pro_w_jean_5.png",
          520000.0, 416000.0, ProductType.JEANS, womenJeans,
          List.of(womenTag, saleTag),    hm,      adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- MEN > TOPS (5 sản phẩm) ----
        // ============================================================
        p("Essential White Crew Tee",      "essential-white-crew-tee",       "SKU-M-TOP-001", "assets/images/pro_m_top_1.png",
          180000.0, 144000.0, ProductType.TSHIRT, menTops,
          List.of(menTag, casualTag),   nike,    adminStaff, customerCust, adminCust, false);

        p("Graphic Print Oversized Tee",   "graphic-print-oversized-tee",    "SKU-M-TOP-002", "assets/images/pro_m_top_2.png",
          250000.0, 200000.0, ProductType.TSHIRT, menTops,
          List.of(menTag, trendTag),    gap,     adminStaff, customerCust, adminCust, false);

        p("Polo Shirt Classic Fit",        "polo-shirt-classic-fit",         "SKU-M-TOP-003", "assets/images/pro_m_top_3.png",
          320000.0, 256000.0, ProductType.TSHIRT, menTops,
          List.of(menTag, premiumTag),  uniqlo,  adminStaff, customerCust, adminCust, false);

        p("Striped Sailor Tee",            "striped-sailor-tee",             "SKU-M-TOP-004", "assets/images/pro_m_top_4.png",
          220000.0, 176000.0, ProductType.TSHIRT, menTops,
          List.of(menTag, newTag),      zara,    adminStaff, customerCust, adminCust, false);

        p("Performance Dry-Fit Tee",       "performance-dry-fit-tee",        "SKU-M-TOP-005", "assets/images/pro_m_top_5.png",
          290000.0, 232000.0, ProductType.TSHIRT, menTops,
          List.of(menTag, sportTag),    adidas,  adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- MEN > SHIRTS (5 sản phẩm) ----
        // ============================================================
        p("Oxford Button-Down Shirt",      "oxford-button-down-shirt",       "SKU-M-SHT-001", "assets/images/pro_m_shirt_1.png",
          380000.0, 304000.0, ProductType.SHIRT, menShirts,
          List.of(menTag, casualTag),   uniqlo,  adminStaff, customerCust, adminCust, false);

        p("Slim Fit Dress Shirt",          "slim-fit-dress-shirt",           "SKU-M-SHT-002", "assets/images/pro_m_shirt_2.png",
          450000.0, 360000.0, ProductType.SHIRT, menShirts,
          List.of(menTag, premiumTag),  zara,    adminStaff, customerCust, adminCust, false);

        p("Flannel Plaid Shirt",           "flannel-plaid-shirt",            "SKU-M-SHT-003", "assets/images/pro_m_shirt_3.png",
          340000.0, 272000.0, ProductType.SHIRT, menShirts,
          List.of(menTag, newTag),      gap,     adminStaff, customerCust, adminCust, false);

        p("Linen Relaxed Shirt",           "linen-relaxed-shirt",            "SKU-M-SHT-004", "assets/images/pro_m_shirt_4.png",
          310000.0, 248000.0, ProductType.SHIRT, menShirts,
          List.of(menTag, saleTag),     hm,      adminStaff, customerCust, adminCust, false);

        p("Luxury Italian Dress Shirt",    "luxury-italian-dress-shirt",     "SKU-M-SHT-005", "assets/images/pro_m_shirt_5.png",
          890000.0, 712000.0, ProductType.SHIRT, menShirts,
          List.of(menTag, luxuryTag),   gucci,   adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- MEN > KNITWEAR (5 sản phẩm) ----
        // ============================================================
        p("Merino Wool Crewneck",          "merino-wool-crewneck",           "SKU-M-KNT-001", "assets/images/pro_m_knit_1.png",
          680000.0, 544000.0, ProductType.TSHIRT, menKnit,
          List.of(menTag, premiumTag),  uniqlo,  adminStaff, customerCust, adminCust, false);

        p("Classic Cable Knit Sweater",    "classic-cable-knit-sweater",     "SKU-M-KNT-002", "assets/images/pro_m_knit_2.png",
          560000.0, 448000.0, ProductType.TSHIRT, menKnit,
          List.of(menTag, trendTag),    burberry,adminStaff, customerCust, adminCust, false);

        p("Slim Turtleneck Knit",          "slim-turtleneck-knit-men",       "SKU-M-KNT-003", "assets/images/pro_m_knit_3.png",
          490000.0, 392000.0, ProductType.TSHIRT, menKnit,
          List.of(menTag, newTag),      zara,    adminStaff, customerCust, adminCust, false);

        p("Half-Zip Knit Pullover",        "half-zip-knit-pullover",         "SKU-M-KNT-004", "assets/images/pro_m_knit_4.png",
          420000.0, 336000.0, ProductType.TSHIRT, menKnit,
          List.of(menTag, casualTag),   hm,      adminStaff, customerCust, adminCust, false);

        p("Chunky Oversized Sweater Men",  "chunky-oversized-sweater-men",   "SKU-M-KNT-005", "assets/images/pro_m_knit_5.png",
          510000.0, 408000.0, ProductType.TSHIRT, menKnit,
          List.of(menTag, saleTag),     gap,     adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- MEN > HOODIES (5 sản phẩm) ----
        // ============================================================
        p("Classic Zip Hoodie",            "classic-zip-hoodie-men",         "SKU-M-HOD-001", "assets/images/pro_m_hoodie_1.png",
          520000.0, 416000.0, ProductType.HOODIE, menHoodies,
          List.of(menTag, newTag),      adidas,  adminStaff, customerCust, adminCust, false);

        p("Heavyweight Pullover Hoodie",   "heavyweight-pullover-hoodie",    "SKU-M-HOD-002", "assets/images/pro_m_hoodie_2.png",
          590000.0, 472000.0, ProductType.HOODIE, menHoodies,
          List.of(menTag, premiumTag),  nike,    adminStaff, customerCust, adminCust, false);

        p("Tech Fleece Hoodie",            "tech-fleece-hoodie",             "SKU-M-HOD-003", "assets/images/pro_m_hoodie_3.png",
          750000.0, 600000.0, ProductType.HOODIE, menHoodies,
          List.of(menTag, sportTag),    nike,    adminStaff, customerCust, adminCust, false);

        p("Camo Print Hoodie",             "camo-print-hoodie-men",          "SKU-M-HOD-004", "assets/images/pro_m_hoodie_4.png",
          430000.0, 344000.0, ProductType.HOODIE, menHoodies,
          List.of(menTag, trendTag),    puma,    adminStaff, customerCust, adminCust, false);

        p("Essential Fleece Hoodie",       "essential-fleece-hoodie",        "SKU-M-HOD-005", "assets/images/pro_m_hoodie_5.png",
          380000.0, 304000.0, ProductType.HOODIE, menHoodies,
          List.of(menTag, saleTag),     gap,     adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- MEN > SHOES (5 sản phẩm) ----
        // ============================================================
        p("Air Max Running Sneakers",      "air-max-running-sneakers",       "SKU-M-SHO-001", "assets/images/pro_m_shoe_1.png",
          850000.0, 680000.0, ProductType.SNEAKER, menShoes,
          List.of(menTag, trendTag),    nike,    adminStaff, customerCust, adminCust, true);

        p("Ultraboost Athletic Shoes",     "ultraboost-athletic-shoes",      "SKU-M-SHO-002", "assets/images/pro_m_shoe_2.png",
          950000.0, 760000.0, ProductType.SNEAKER, menShoes,
          List.of(menTag, sportTag),    adidas,  adminStaff, customerCust, adminCust, true);

        p("Classic Stan Smith",            "classic-stan-smith",             "SKU-M-SHO-003", "assets/images/pro_m_shoe_3.png",
          720000.0, 576000.0, ProductType.SNEAKER, menShoes,
          List.of(menTag, casualTag),   adidas,  adminStaff, customerCust, adminCust, true);

        p("Puma RS-X Sneakers",            "puma-rsx-sneakers",              "SKU-M-SHO-004", "assets/images/pro_m_shoe_4.png",
          690000.0, 552000.0, ProductType.SNEAKER, menShoes,
          List.of(menTag, newTag),      puma,    adminStaff, customerCust, adminCust, true);

        p("Luxury Derby Leather Shoes",    "luxury-derby-leather-shoes",     "SKU-M-SHO-005", "assets/images/pro_m_shoe_5.png",
          1800000.0, 1440000.0, ProductType.SNEAKER, menShoes,
          List.of(menTag, luxuryTag),   gucci,   adminStaff, customerCust, adminCust, true);

        // ============================================================
        // ---- MEN > JEANS (5 sản phẩm) ----
        // ============================================================
        p("Slim Fit Dark Wash Jeans",      "slim-fit-dark-wash-jeans",       "SKU-M-JNS-001", "assets/images/pro_m_jean_1.png",
          480000.0, 384000.0, ProductType.JEANS, menJeans,
          List.of(menTag, trendTag),    levis,   adminStaff, customerCust, adminCust, false);

        p("Straight Leg Classic Jeans",    "straight-leg-classic-jeans",     "SKU-M-JNS-002", "assets/images/pro_m_jean_2.png",
          420000.0, 336000.0, ProductType.JEANS, menJeans,
          List.of(menTag, casualTag),   levis,   adminStaff, customerCust, adminCust, false);

        p("Skinny Stretch Jeans Men",      "skinny-stretch-jeans-men",       "SKU-M-JNS-003", "assets/images/pro_m_jean_3.png",
          450000.0, 360000.0, ProductType.JEANS, menJeans,
          List.of(menTag, newTag),      zara,    adminStaff, customerCust, adminCust, false);

        p("Relaxed Cargo Denim Pants",     "relaxed-cargo-denim-pants",      "SKU-M-JNS-004", "assets/images/pro_m_jean_4.png",
          510000.0, 408000.0, ProductType.JEANS, menJeans,
          List.of(menTag, saleTag),     gap,     adminStaff, customerCust, adminCust, false);

        p("Distressed Biker Jeans Men",    "distressed-biker-jeans-men",     "SKU-M-JNS-005", "assets/images/pro_m_jean_5.png",
          560000.0, 448000.0, ProductType.JEANS, menJeans,
          List.of(menTag, trendTag),    levis,   adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- KIDS > TOPS (5 sản phẩm) ----
        // ============================================================
        p("Dino Print Kids Tee",           "dino-print-kids-tee",            "SKU-K-TOP-001", "https://picsum.photos/id/50/600/600",
          150000.0, 120000.0, ProductType.TSHIRT, kidsTops,
          List.of(kidsTag, newTag),    nike,    adminStaff, customerCust, adminCust, false);

        p("Unicorn Sparkle Top",           "unicorn-sparkle-top",            "SKU-K-TOP-002", "https://picsum.photos/id/51/600/600",
          180000.0, 144000.0, ProductType.TSHIRT, kidsTops,
          List.of(kidsTag, trendTag),  zara,    adminStaff, customerCust, adminCust, false);

        p("Cartoon Character Crop Tee",    "cartoon-character-crop-tee",     "SKU-K-TOP-003", "https://picsum.photos/id/52/600/600",
          140000.0, 112000.0, ProductType.TSHIRT, kidsTops,
          List.of(kidsTag, saleTag),   hm,      adminStaff, customerCust, adminCust, false);

        p("Rainbow Stripe Kids Top",       "rainbow-stripe-kids-top",        "SKU-K-TOP-004", "https://picsum.photos/id/53/600/600",
          165000.0, 132000.0, ProductType.TSHIRT, kidsTops,
          List.of(kidsTag, casualTag), gap,     adminStaff, customerCust, adminCust, false);

        p("Sports Performance Kids Tee",   "sports-performance-kids-tee",    "SKU-K-TOP-005", "https://picsum.photos/id/54/600/600",
          200000.0, 160000.0, ProductType.TSHIRT, kidsTops,
          List.of(kidsTag, sportTag),  adidas,  adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- KIDS > SHIRTS (5 sản phẩm) ----
        // ============================================================
        p("Kids Oxford School Shirt",      "kids-oxford-school-shirt",       "SKU-K-SHT-001", "https://picsum.photos/id/55/600/600",
          195000.0, 156000.0, ProductType.SHIRT, kidsShirts,
          List.of(kidsTag, casualTag), uniqlo,  adminStaff, customerCust, adminCust, false);

        p("Floral Print Kids Shirt",       "floral-print-kids-shirt",        "SKU-K-SHT-002", "https://picsum.photos/id/56/600/600",
          210000.0, 168000.0, ProductType.SHIRT, kidsShirts,
          List.of(kidsTag, newTag),    zara,    adminStaff, customerCust, adminCust, false);

        p("Plaid Check Kids Shirt",        "plaid-check-kids-shirt",         "SKU-K-SHT-003", "https://picsum.photos/id/57/600/600",
          185000.0, 148000.0, ProductType.SHIRT, kidsShirts,
          List.of(kidsTag, saleTag),   hm,      adminStaff, customerCust, adminCust, false);

        p("Button Up Poplin Kids Shirt",   "button-up-poplin-kids-shirt",    "SKU-K-SHT-004", "https://picsum.photos/id/58/600/600",
          220000.0, 176000.0, ProductType.SHIRT, kidsShirts,
          List.of(kidsTag, trendTag),  gap,     adminStaff, customerCust, adminCust, false);

        p("Polo Kids Shirt",               "polo-kids-shirt",                "SKU-K-SHT-005", "https://picsum.photos/id/59/600/600",
          240000.0, 192000.0, ProductType.SHIRT, kidsShirts,
          List.of(kidsTag, premiumTag),uniqlo,  adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- KIDS > KNITWEAR (5 sản phẩm) ----
        // ============================================================
        p("Kids Rainbow Knit Sweater",     "kids-rainbow-knit-sweater",      "SKU-K-KNT-001", "https://picsum.photos/id/60/600/600",
          280000.0, 224000.0, ProductType.TSHIRT, kidsKnit,
          List.of(kidsTag, newTag),    hm,      adminStaff, customerCust, adminCust, false);

        p("Teddy Bear Cable Knit",         "teddy-bear-cable-knit",          "SKU-K-KNT-002", "https://picsum.photos/id/61/600/600",
          320000.0, 256000.0, ProductType.TSHIRT, kidsKnit,
          List.of(kidsTag, trendTag),  zara,    adminStaff, customerCust, adminCust, false);

        p("Kids Chunky Cardigan",          "kids-chunky-cardigan",           "SKU-K-KNT-003", "https://picsum.photos/id/62/600/600",
          260000.0, 208000.0, ProductType.TSHIRT, kidsKnit,
          List.of(kidsTag, saleTag),   gap,     adminStaff, customerCust, adminCust, false);

        p("Star Print Kids Pullover",      "star-print-kids-pullover",       "SKU-K-KNT-004", "https://picsum.photos/id/63/600/600",
          295000.0, 236000.0, ProductType.TSHIRT, kidsKnit,
          List.of(kidsTag, casualTag), uniqlo,  adminStaff, customerCust, adminCust, false);

        p("Animal Pattern Knit Kids",      "animal-pattern-knit-kids",       "SKU-K-KNT-005", "https://picsum.photos/id/64/600/600",
          310000.0, 248000.0, ProductType.TSHIRT, kidsKnit,
          List.of(kidsTag, newTag),    hm,      adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- KIDS > HOODIES (5 sản phẩm) ----
        // ============================================================
        p("Superhero Kids Hoodie",         "superhero-kids-hoodie",          "SKU-K-HOD-001", "https://picsum.photos/id/65/600/600",
          295000.0, 236000.0, ProductType.HOODIE, kidsHoodies,
          List.of(kidsTag, newTag),    nike,    adminStaff, customerCust, adminCust, false);

        p("Pastel Zip-Up Kids Hoodie",     "pastel-zip-up-kids-hoodie",      "SKU-K-HOD-002", "https://picsum.photos/id/66/600/600",
          270000.0, 216000.0, ProductType.HOODIE, kidsHoodies,
          List.of(kidsTag, trendTag),  adidas,  adminStaff, customerCust, adminCust, false);

        p("Fuzzy Bear Ear Hoodie",         "fuzzy-bear-ear-hoodie",          "SKU-K-HOD-003", "https://picsum.photos/id/67/600/600",
          340000.0, 272000.0, ProductType.HOODIE, kidsHoodies,
          List.of(kidsTag, saleTag),   zara,    adminStaff, customerCust, adminCust, false);

        p("Dino Tail Hoodie Kids",         "dino-tail-hoodie-kids",          "SKU-K-HOD-004", "https://picsum.photos/id/68/600/600",
          315000.0, 252000.0, ProductType.HOODIE, kidsHoodies,
          List.of(kidsTag, casualTag), gap,     adminStaff, customerCust, adminCust, false);

        p("Sport Active Kids Hoodie",      "sport-active-kids-hoodie",       "SKU-K-HOD-005", "https://picsum.photos/id/69/600/600",
          280000.0, 224000.0, ProductType.HOODIE, kidsHoodies,
          List.of(kidsTag, sportTag),  puma,    adminStaff, customerCust, adminCust, false);

        // ============================================================
        // ---- KIDS > SHOES (5 sản phẩm) ----
        // ============================================================
        p("Kids Velcro Sport Sneakers",    "kids-velcro-sport-sneakers",     "SKU-K-SHO-001", "https://picsum.photos/id/70/600/600",
          350000.0, 280000.0, ProductType.SNEAKER, kidsShoes,
          List.of(kidsTag, saleTag),   nike,    adminStaff, customerCust, adminCust, true);

        p("Light-Up LED Sneakers Kids",    "light-up-led-sneakers-kids",     "SKU-K-SHO-002", "https://picsum.photos/id/71/600/600",
          390000.0, 312000.0, ProductType.SNEAKER, kidsShoes,
          List.of(kidsTag, newTag),    adidas,  adminStaff, customerCust, adminCust, true);

        p("Kids Slip-On Canvas Shoes",     "kids-slip-on-canvas-shoes",      "SKU-K-SHO-003", "https://picsum.photos/id/72/600/600",
          270000.0, 216000.0, ProductType.SNEAKER, kidsShoes,
          List.of(kidsTag, casualTag), uniqlo,  adminStaff, customerCust, adminCust, true);

        p("Cartoon Printed Kids Runners",  "cartoon-printed-kids-runners",   "SKU-K-SHO-004", "https://picsum.photos/id/73/600/600",
          310000.0, 248000.0, ProductType.SNEAKER, kidsShoes,
          List.of(kidsTag, trendTag),  puma,    adminStaff, customerCust, adminCust, true);

        p("Kids School Leather Shoes",     "kids-school-leather-shoes",      "SKU-K-SHO-005", "https://picsum.photos/id/74/600/600",
          420000.0, 336000.0, ProductType.SNEAKER, kidsShoes,
          List.of(kidsTag, premiumTag),zara,    adminStaff, customerCust, adminCust, true);

        // ============================================================
        // ---- KIDS > JEANS (5 sản phẩm) ----
        // ============================================================
        p("Slim Fit Kids Jeans",           "slim-fit-kids-jeans",            "SKU-K-JNS-001", "https://picsum.photos/id/75/600/600",
          280000.0, 224000.0, ProductType.JEANS, kidsJeans,
          List.of(kidsTag, trendTag),  levis,   adminStaff, customerCust, adminCust, false);

        p("Elastic Waist Kids Jeans",      "elastic-waist-kids-jeans",       "SKU-K-JNS-002", "https://picsum.photos/id/76/600/600",
          250000.0, 200000.0, ProductType.JEANS, kidsJeans,
          List.of(kidsTag, casualTag), hm,      adminStaff, customerCust, adminCust, false);

        p("Knee Patch Denim Kids",         "knee-patch-denim-kids",          "SKU-K-JNS-003", "https://picsum.photos/id/77/600/600",
          260000.0, 208000.0, ProductType.JEANS, kidsJeans,
          List.of(kidsTag, newTag),    zara,    adminStaff, customerCust, adminCust, false);

        p("Adjustable Waist Jeans Kids",   "adjustable-waist-jeans-kids",    "SKU-K-JNS-004", "https://picsum.photos/id/78/600/600",
          295000.0, 236000.0, ProductType.JEANS, kidsJeans,
          List.of(kidsTag, saleTag),   gap,     adminStaff, customerCust, adminCust, false);

        p("Wide Leg Kids Jeans",           "wide-leg-kids-jeans",            "SKU-K-JNS-005", "https://picsum.photos/id/79/600/600",
          310000.0, 248000.0, ProductType.JEANS, kidsJeans,
          List.of(kidsTag, trendTag),  levis,   adminStaff, customerCust, adminCust, false);

        System.out.println(">> Seeding sản phẩm hoàn tất: 90 sản phẩm (5 × 18 subcategories) với ảnh tương thích!");

        // ============================================================
        // BƯỚC 10: SHIPPING ADDRESSES
        // ============================================================
        ShippingAddress addr1 = new ShippingAddress();
        addr1.setFullName("Hua Khánh Huy");
        addr1.setPhoneNumber("0987654321");
        addr1.setStreetAddress("123 Nguyễn Trãi, Phường 2");
        addr1.setCity("Quận 5");
        addr1.setState("TP. Hồ Chí Minh");
        addr1.setZipCode("70000");
        addr1.setCountry("Vietnam");
        addr1.setIsDefault(true);
        addr1.setUser(customerStaff);
        shippingAddressRepository.save(addr1);

        ShippingAddress addr2 = new ShippingAddress();
        addr2.setFullName("Hua Khánh Huy (Cơ quan)");
        addr2.setPhoneNumber("0987654321");
        addr2.setStreetAddress("456 Lê Lợi, Bến Nghé");
        addr2.setCity("Quận 1");
        addr2.setState("TP. Hồ Chí Minh");
        addr2.setZipCode("70000");
        addr2.setCountry("Vietnam");
        addr2.setIsDefault(false);
        addr2.setUser(customerStaff);
        shippingAddressRepository.save(addr2);

        // ============================================================
        // BƯỚC 11: PAYMENT CARDS
        // ============================================================
        PaymentCard card1 = new PaymentCard();
        card1.setCardHolderName("HUA KHANH HUY");
        card1.setCardNumber("1234567812345678");
        card1.setExpiryDate("12/28");
        card1.setCardType("Visa");
        card1.setIsDefault(true);
        card1.setUser(customerStaff);
        paymentCardRepository.save(card1);

        PaymentCard card2 = new PaymentCard();
        card2.setCardHolderName("HUA KHANH HUY");
        card2.setCardNumber("8765432187654321");
        card2.setExpiryDate("06/29");
        card2.setCardType("Mastercard");
        card2.setIsDefault(false);
        card2.setUser(customerStaff);
        paymentCardRepository.save(card2);

        System.out.println("=== ShopApp DataSeeder: Hoàn tất! Tổng cộng 90 sản phẩm, 18 subcategories, 10 tags ===");
    }

    // ============================================================
    // HELPER METHODS
    // ============================================================

    private Country saveCountry(String iso, String name, String upper, String iso3, short numCode, int phoneCode) {
        return countryRepository.findByIso(iso).orElseGet(() -> {
            Country c = new Country();
            c.setIso(iso);
            c.setName(name);
            c.setUpperName(upper);
            c.setIso3(iso3);
            c.setNumCode(numCode);
            c.setPhoneCode(phoneCode);
            return countryRepository.save(c);
        });
    }

    private Supplier saveSupplier(String name, String company, String phone, String address, Country country, StaffAccount creator) {
        Supplier s = new Supplier();
        s.setSupplierName(name);
        s.setCompany(company);
        s.setPhoneNumber(phone);
        s.setAddressLine1(address);
        s.setCountry(country);
        s.setCity("N/A");
        s.setCreatedBy(creator);
        return supplierRepository.save(s);
    }

    private Category saveCategory(String name, String desc, String icon, String img, boolean active, Category parent, StaffAccount creator) {
        Category cat = new Category(name, desc, icon, img, active, parent);
        cat.setCreatedBy(creator);
        return categoryRepository.save(cat);
    }

    private Tag saveTag(String name, String icon) {
        Tag t = new Tag();
        t.setTagName(name);
        t.setIcon(icon);
        return tagRepository.save(t);
    }

    private void savePromoCode(String code, int discountPercent) {
        PromoCode pc = promoCodeRepository.findByCode(code).orElseGet(() -> {
            PromoCode p = new PromoCode();
            p.setCode(code);
            return p;
        });
        pc.setDiscountPercent(discountPercent);
        pc.setExpiryDate(Instant.now().plus(30, ChronoUnit.DAYS));
        pc.setActive(true);
        promoCodeRepository.save(pc);
    }

    private void p(String name, String slug, String sku, String imageUrl,
                   Double regPrice, Double disPrice, ProductType type, Category category,
                   List<Tag> tags, Supplier supplier, StaffAccount creator,
                   Customer customerCust, Customer adminCust, boolean isShoes) {

        Product prod = new Product();
        prod.setProductName(name);
        prod.setSku(sku);
        prod.setSlug(slug);
        prod.setImageUrl(imageUrl);
        prod.setRegularPrice(regPrice);
        prod.setDiscountPrice(disPrice);
        prod.setBuyingPrice(regPrice * 0.5);
        prod.setQuantity(100);
        prod.setShortDescription(
            "Sản phẩm chất lượng cao từ thương hiệu " + supplier.getSupplierName()
            + " – thiết kế hiện đại, chất liệu cao cấp."
        );
        prod.setProductDescription(
            "Được làm từ chất liệu cao cấp, mềm mại và bền màu. "
            + supplier.getSupplierName() + " mang đến trải nghiệm thời trang tuyệt vời cho người mặc, "
            + "phù hợp cho các hoạt động hàng ngày và những dịp đặc biệt."
        );
        prod.setProductType(type);
        prod.setPublished(true);
        prod.setCreatedBy(creator);
        prod = productRepository.save(prod);

        // Category
        ProductCategory pc = new ProductCategory();
        pc.setProduct(prod);
        pc.setCategory(category);
        productCategoryRepository.save(pc);

        // Tags
        for (Tag tag : tags) {
            ProductTag pt = new ProductTag();
            pt.setProduct(prod);
            pt.setTag(tag);
            productTagRepository.save(pt);
        }

        // Supplier
        ProductSupplier ps = new ProductSupplier();
        ps.setProduct(prod);
        ps.setSupplier(supplier);
        productSupplierRepository.save(ps);

        // Variants
        String[] sizes  = isShoes ? new String[]{"36", "37", "38", "39", "40", "41", "42"} : new String[]{"XS", "S", "M", "L", "XL", "XXL"};
        String[] colors = {"Black", "White", "Navy", "Grey", "Beige"};
        for (String size : sizes) {
            for (String color : colors) {
                ProductVariant pv = new ProductVariant();
                pv.setProduct(prod);
                pv.setSize(size);
                pv.setColor(color);
                pv.setStock(20);
                pv.setPrice(prod.getDiscountPrice());
                pv.setSku(prod.getSku() + "-" + size + "-" + color.toUpperCase());
                productVariantRepository.save(pv);
            }
        }

        // Reviews
        Review r1 = new Review();
        r1.setProduct(prod);
        r1.setCustomer(customerCust);
        r1.setRating(5);
        r1.setComment("Sản phẩm tuyệt vời! Vải mềm mại, form đẹp, mặc rất thoải mái. Rất đáng tiền!");
        r1.setImages(List.of("assets/images/cmt1.png", "assets/images/cmt2.png"));
        reviewRepository.save(r1);

        Review r2 = new Review();
        r2.setProduct(prod);
        r2.setCustomer(adminCust);
        r2.setRating(4);
        r2.setComment("Giao hàng nhanh, đóng gói cẩn thận, sản phẩm đúng như mô tả. Sẽ ủng hộ tiếp!");
        r2.setImages(List.of("assets/images/cmt3.png"));
        reviewRepository.save(r2);
    }
}
