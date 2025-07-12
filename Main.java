import java.util.*;

public class Main {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        int[] apples = new int[n];
        for (int i = 0; i < n; i++) {
            apples[i] = sc.nextInt();
        }
        int H = sc.nextInt();

        int left = 1, right = Arrays.stream(apples).max().getAsInt();
        int result = right;

        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (canFinish(apples, mid, H)) {
                result = mid;
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        System.out.println(result);
    }

    static boolean canFinish(int[] apples, int m, int H) {
        long totalTime = 0;
        for (int apple : apples) {
            totalTime += (apple + m - 1) / m;
            if (totalTime > H) return false;
        }
        return true;
    }
}