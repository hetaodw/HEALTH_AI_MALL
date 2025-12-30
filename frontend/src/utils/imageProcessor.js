export class ImageProcessor {
  static async resizeImage(file, options = {}) {
    const {
      maxWidth = 800,
      maxHeight = 800,
      quality = 0.9,
      aspectRatio = null
    } = options;

    return new Promise((resolve, reject) => {
      const img = new Image();
      const reader = new FileReader();

      reader.onload = (e) => {
        img.src = e.target.result;
      };

      img.onload = () => {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');

        let width = img.width;
        let height = img.height;

        if (aspectRatio) {
          const targetRatio = aspectRatio;
          const currentRatio = width / height;

          if (currentRatio > targetRatio) {
            width = height * targetRatio;
          } else {
            height = width / targetRatio;
          }

          const offsetX = (img.width - width) / 2;
          const offsetY = (img.height - height) / 2;

          canvas.width = width;
          canvas.height = height;
          ctx.drawImage(img, offsetX, offsetY, width, height, 0, 0, width, height);
        } else {
          if (width > maxWidth) {
            height = (maxWidth / width) * height;
            width = maxWidth;
          }

          if (height > maxHeight) {
            width = (maxHeight / height) * width;
            height = maxHeight;
          }

          canvas.width = width;
          canvas.height = height;
          ctx.drawImage(img, 0, 0, width, height);
        }

        canvas.toBlob((blob) => {
          const resizedFile = new File([blob], file.name, {
            type: file.type,
            lastModified: Date.now()
          });
          resolve(resizedFile);
        }, file.type, quality);
      };

      img.onerror = () => {
        reject(new Error('图片加载失败'));
      };

      reader.onerror = () => {
        reject(new Error('文件读取失败'));
      };

      reader.readAsDataURL(file);
    });
  }

  static async createThumbnail(file, size = 200) {
    return this.resizeImage(file, {
      maxWidth: size,
      maxHeight: size,
      quality: 0.85
    });
  }

  static async createAvatar(file, size = 300) {
    return this.resizeImage(file, {
      maxWidth: size,
      maxHeight: size,
      quality: 0.9
    });
  }

  static async createDetailImage(file) {
    return this.resizeImage(file, {
      maxWidth: 1920,
      maxHeight: 1080,
      quality: 0.85,
      aspectRatio: 16 / 9
    });
  }

  static async createCoverImage(file) {
    return this.resizeImage(file, {
      maxWidth: 800,
      maxHeight: 600,
      quality: 0.9
    });
  }

  static async validateImage(file, options = {}) {
    const {
      maxSize = 5 * 1024 * 1024,
      allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
      minWidth = 0,
      minHeight = 0
    } = options;

    if (!allowedTypes.includes(file.type)) {
      throw new Error('不支持的文件类型，仅支持 JPG、PNG、GIF、WebP 格式');
    }

    if (file.size > maxSize) {
      const maxSizeMB = (maxSize / (1024 * 1024)).toFixed(1);
      throw new Error(`文件大小超过限制，最大允许 ${maxSizeMB}MB`);
    }

    if (minWidth > 0 || minHeight > 0) {
      return new Promise((resolve, reject) => {
        const img = new Image();
        const reader = new FileReader();

        reader.onload = (e) => {
          img.src = e.target.result;
        };

        img.onload = () => {
          if (img.width < minWidth || img.height < minHeight) {
            reject(new Error(`图片尺寸过小，最小要求 ${minWidth}x${minHeight}`));
          } else {
            resolve(true);
          }
        };

        img.onerror = () => {
          reject(new Error('图片加载失败，无法验证尺寸'));
        };

        reader.readAsDataURL(file);
      });
    }

    return true;
  }

  static async getDimensions(file) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const reader = new FileReader();

      reader.onload = (e) => {
        img.src = e.target.result;
      };

      img.onload = () => {
        resolve({
          width: img.width,
          height: img.height,
          ratio: img.width / img.height
        });
      };

      img.onerror = () => {
        reject(new Error('图片加载失败'));
      };

      reader.readAsDataURL(file);
    });
  }
}
